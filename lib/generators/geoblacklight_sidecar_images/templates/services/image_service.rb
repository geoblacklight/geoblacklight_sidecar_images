# frozen_string_literal: true
require "addressable/uri"
require 'rack/mime'

class ImageService
  attr_reader :document
  attr_writer :metadata, :logger

  def initialize(document)
    @document = document

    @metadata = Hash.new
    @metadata['solr_doc_id'] = document.id
    @metadata['solr_version'] = @document.sidecar.version

    @document.sidecar.image_state.transition_to!(:processing, @metadata)

    @logger ||= ActiveSupport::TaggedLogging.new(
      Logger.new(
        File.join(
          Rails.root, '/log/', "image_service_#{Rails.env}.log"
        )
      )
    )
  end

  # Stores the document's image in ActiveStorage
  # @return [Boolean]
  #
  # @TODO: EWL
  def store
    # Gentle hands.
    sleep(1)

    sidecar = @document.sidecar
    io_file = image_tempfile(@document.id)

    if @metadata['placeheld'] == false
      sidecar.image.attach(
        io: io_file,
        filename: "#{@document.id}#{image_extension}",
        content_type: remote_content_type
      )
      @document.sidecar.image_state.transition_to!(:succeeded, @metadata)
    else
      @document.sidecar.image_state.transition_to!(:placeheld, @metadata)
    end

    log_output

  rescue Exception => invalid
    @metadata['exception'] = invalid.inspect
    @document.sidecar.image_state.transition_to!(:failed, @metadata)

    log_output
  end

  private

  def image_tempfile(document_id)
    @metadata['remote_content_type']  = remote_content_type
    @metadata['viewer_protocol']      = @document.viewer_protocol
    @metadata['image_url']            = image_url
    @metadata['gblsi_thumbnail_uri']  = gblsi_thumbnail_uri
    @metadata['service_url']          = service_url
    @metadata['image_extension']      = image_extension
    @metadata['placeheld']            = false

    temp_file = Tempfile.new([document_id, image_extension])
    temp_file.binmode
    temp_file.write(image_data)
    temp_file.rewind

    @metadata['image_tempfile'] = temp_file.inspect
    temp_file
  end

  # Returns geoserver auth credentials if the document is a restriced Local WMS layer.
  def geoserver_credentials
    return unless restricted_wms_layer?
    Settings.PROXY_GEOSERVER_AUTH.gsub('Basic ', '')
  end

  # Tests if geoserver credentials are set beyond the default.
  def geoserver_credentials_valid?
    Settings.PROXY_GEOSERVER_AUTH != 'Basic base64encodedusername:password'
  end

  # Tests if local thumbnail method is configured
  def gblsi_thumbnail_field?
    Settings.GBLSI_THUMBNAIL_FIELD
  end

  def gblsi_thumbnail_uri
    if gblsi_thumbnail_field? && @document[Settings.GBLSI_THUMBNAIL_FIELD]
      @document[Settings.GBLSI_THUMBNAIL_FIELD]
    else
      false
    end
  end

  # Generates hash containing thumbnail mime_type and image.
  def image_data
    return nil unless image_url
    remote_image
  end

  # Gets remote content type from URL. On error, placehold the image.
  def remote_content_type
    auth = geoserver_credentials

    uri = Addressable::URI.parse(image_url)

    conn = Faraday.new(url: uri.normalize.to_s) do |b|
      b.use FaradayMiddleware::FollowRedirects
      b.adapter :net_http
    end

    conn.options.timeout = timeout
    conn.authorization :Basic, auth if auth

    conn.head.headers['content-type']
  rescue Faraday::Error::ConnectionFailed
    @metadata['error'] = "Faraday::Error::ConnectionFailed"
    @metadata['placeheld'] = true
  rescue Faraday::Error::TimeoutError
    @metadata['error'] = "Faraday::Error::TimeoutError"
    @metadata['placeheld'] = true
  rescue Exception => e
    @metadata['error'] = e.inspect
    @metadata['placeheld'] = true
  end

  # Gets thumbnail image from URL. On error, placehold image.
  def remote_image
    auth = geoserver_credentials

    uri = Addressable::URI.parse(image_url)

    if uri.scheme.include?("http")
      conn = Faraday.new(url: uri.normalize.to_s) do |b|
        b.use FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end

      conn.options.timeout = timeout
      conn.authorization :Basic, auth if auth
      conn.get.body
    else
      return nil
    end
  rescue Faraday::Error::ConnectionFailed
    @metadata['error'] = "Faraday::Error::ConnectionFailed"
    @metadata['placeheld'] = true
  rescue Faraday::Error::TimeoutError
    @metadata['error'] = "Faraday::Error::TimeoutError"
    @metadata['placeheld'] = true
  end

  # Returns the thumbnail url.
  # If the layer is restriced Local WMS, and the geoserver credentials
  # have not been set beyond the default, then a thumbnail url from
  # dct references is used instead.
  def image_url
    @image_url ||= begin
      if gblsi_thumbnail_uri
        gblsi_thumbnail_uri
      elsif restricted_scanned_map?
        image_reference
      elsif restricted_wms_layer? && !geoserver_credentials_valid?
        image_reference
      else
        service_url || image_reference
      end
    end
  end

  # Determines the image file extension
  # Necessary for writing a tempfile
  def image_extension
    @image_extension ||= Rack::Mime::MIME_TYPES.rassoc(remote_content_type).try(:first) || '.png'
  end

  # Checks if the document is Local restriced access and is a scanned map.
  def restricted_scanned_map?
    @document.local_restricted? && @document['layer_geom_type_s'] == 'Image'
  end

  # Checks if the document is Local restriced access and is a wms layer.
  def restricted_wms_layer?
    @document.local_restricted? && @document.viewer_protocol == 'wms'
  end

  # Gets the url for a specific service endpoint if the item is
  # public, has the same institution as the GBL instance, and the viewer
  # protocol is not 'map' or nil. A module name is then dynamically generated
  # from the viewer protocol, and if it's loaded, the image_url
  # method is called.
  def service_url
    @service_url ||= begin
      return unless @document.available?
      protocol = @document.viewer_protocol
      if protocol == 'map' || protocol.nil?
        @metadata['error'] = "Unsupported viewer protocol"
        @metadata['placeheld'] = true
        return
      end
      "ImageService::#{protocol.camelcase}".constantize.image_url(@document, image_size)
    rescue NameError
      @metadata['error'] = "service_url NameError"
      @metadata['placeheld'] = true
      return nil
    end
  end

  # Retreives a url to a static thumbnail from the document's dct_references field, if it exists.
  def image_reference
    return nil if @document[@document.references.reference_field].nil?
    JSON.parse(@document[@document.references.reference_field])['http://schema.org/thumbnailUrl']
  end

  # Default thumbnail size.
  def image_size
    300
  end

  # Faraday timeout value.
  def timeout
    30
  end

  # Capture metadata within image harvest log
  def log_output
    @metadata["state"] = @document.sidecar.image_state.current_state
    @metadata.each do |key,value|
      @logger.tagged(@document.id, key.to_s) { @logger.info value }
    end
  end
end
