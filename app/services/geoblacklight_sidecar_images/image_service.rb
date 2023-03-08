# frozen_string_literal: true

require "addressable/uri"
require "mimemagic"

module GeoblacklightSidecarImages
  class ImageService
    attr_reader :document
    attr_writer :metadata, :logger

    def initialize(document)
      @document = document

      @metadata = {}
      @metadata["solr_doc_id"] = document.id
      @metadata["solr_version"] = @document.sidecar.version
      @metadata["placeheld"] = false

      @document.sidecar.image_state.transition_to!(:processing, @metadata)

      @logger ||= ActiveSupport::TaggedLogging.new(
        Logger.new(
          Rails.root.join("log", "image_service_#{Rails.env}.log")
        )
      )
    end

    # Stores the document's image in ActiveStorage
    # @return [Boolean]
    #
    def store
      # Gentle hands
      sleep(1)

      io_file = image_tempfile(@document.id)

      if io_file.nil? || @metadata["placeheld"] == true
        @document.sidecar.image_state.transition_to!(:placeheld, @metadata)
      else
        attach_io(io_file)
      end

      log_output
    rescue => e
      @metadata["exception"] = e.inspect
      @document.sidecar.image_state.transition_to!(:failed, @metadata)

      log_output
    end

    private

    def image_tempfile(document_id)
      @metadata["viewer_protocol"] = @document.viewer_protocol
      @metadata["image_url"] = image_url
      @metadata["gblsi_thumbnail_uri"] = gblsi_thumbnail_uri

      return nil unless image_data && @metadata["placeheld"] == false

      temp_file = Tempfile.new("#{document_id}.tmp")
      temp_file.binmode
      temp_file.write(image_data)
      temp_file.rewind

      @metadata["image_tempfile"] = temp_file.inspect
      temp_file
    end

    def attach_io(io)
      # Remote content-type headers are untrustworthy
      # Pull the mimetype and file extension via MimeMagic
      mm = MimeMagic.by_magic(File.open(io))

      @metadata["MimeMagic_type"] = mm.type
      @metadata["MimeMagic_mediatype"] = mm.mediatype
      @metadata["MimeMagic_subtype"] = mm.subtype

      if mm.mediatype == "image"
        @document.sidecar.image.attach(
          io: io,
          filename: "#{@document.id}.#{mm.subtype}",
          content_type: mm.type
        )
        @document.sidecar.image_state.transition_to!(:succeeded, @metadata)
      else
        @document.sidecar.image_state.transition_to!(:placeheld, @metadata)
      end
    end

    # Returns geoserver auth credentials if the document is a restriced Local WMS layer.
    def geoserver_credentials
      return unless restricted_wms_layer?

      Settings.PROXY_GEOSERVER_AUTH.gsub("Basic ", "")
    end

    # Tests if geoserver credentials are set beyond the default.
    def geoserver_credentials_valid?
      Settings.PROXY_GEOSERVER_AUTH != "Basic base64encodedusername:password"
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

    # Gets thumbnail image from URL. On error, placehold image.
    def remote_image
      auth = geoserver_credentials

      uri = Addressable::URI.parse(image_url)

      return nil unless uri.scheme.include?("http")

      conn = Faraday.new(url: uri.normalize.to_s) do |b|
        b.use Geoblacklight::FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end

      conn.options.timeout = timeout
      conn.authorization :Basic, auth if auth
      conn.get.body
    rescue Faraday::ConnectionFailed
      @metadata["error"] = "Faraday::ConnectionFailed"
      @metadata["placeheld"] = true
      nil
    rescue Faraday::TimeoutError
      @metadata["error"] = "Faraday::TimeoutError"
      @metadata["placeheld"] = true
      nil
    end

    # Returns the thumbnail url.
    # If the layer is restriced Local WMS, and the geoserver credentials
    # have not been set beyond the default, then a thumbnail url from
    # dct references is used instead.
    def image_url
      @image_url ||= if gblsi_thumbnail_uri
        gblsi_thumbnail_uri
      elsif restricted_scanned_map?
        image_reference
      elsif restricted_wms_layer? && !geoserver_credentials_valid?
        image_reference
      else
        service_url || image_reference
      end
    end

    # Checks if the document is Local restriced access and is a scanned map.
    def restricted_scanned_map?
      @document.local_restricted? && @document["layer_geom_type_s"] == "Image"
    end

    # Checks if the document is Local restriced access and is a wms layer.
    def restricted_wms_layer?
      @document.local_restricted? && @document.viewer_protocol == "wms"
    end

    # Gets the url for a specific service endpoint if the item is
    # public, has the same institution as the GBL instance, and the viewer
    # protocol is not 'map' or nil. A module name is then dynamically generated
    # from the viewer protocol, and if it's loaded, the image_url
    # method is called.
    def service_url
      # Follow image_url instead
      return nil if gblsi_thumbnail_uri

      @service_url ||=
        begin
          return unless @document.available?

          protocol = @document.viewer_protocol

          if protocol == "map" || protocol.nil?
            @metadata["error"] = "Unsupported viewer protocol"
            @metadata["placeheld"] = true
            return nil
          end
          "GeoblacklightSidecarImages::ImageService::#{protocol.camelcase}".constantize.image_url(@document, image_size)
        rescue NameError
          @metadata["error"] = "service_url NameError"
          @metadata["placeheld"] = true
          return nil
        end
    end

    # Retreives a url to a static thumbnail from the document's dct_references field, if it exists.
    def image_reference
      return nil if @document[@document.references.reference_field].nil?

      JSON.parse(@document[@document.references.reference_field])["http://schema.org/thumbnailUrl"]
    end

    # Default image size.
    def image_size
      1500
    end

    # Faraday timeout value.
    def timeout
      30
    end

    # Capture metadata within image harvest log
    def log_output
      @metadata["state"] = @document.sidecar.image_state.current_state
      @metadata.each do |key, value|
        @logger.tagged(@document.id, key.to_s) { @logger.info value }
      end
    end
  end
end
