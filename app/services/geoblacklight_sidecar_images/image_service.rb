# frozen_string_literal: true

require "addressable/uri"
require "faraday/follow_redirects"
require "ipaddr"
require "marcel"
require "resolv"

module GeoblacklightSidecarImages
  class ImageService
    MAX_BODY_BYTES = 10 * 1024 * 1024

    ADAPTERS = {
      "wms" => "GeoblacklightSidecarImages::ImageService::Wms",
      "iiif" => "GeoblacklightSidecarImages::ImageService::Iiif",
      "tiled_map_layer" => "GeoblacklightSidecarImages::ImageService::EsriThumbnail",
      "dynamic_map_layer" => "GeoblacklightSidecarImages::ImageService::EsriThumbnail",
      "image_map_layer" => "GeoblacklightSidecarImages::ImageService::EsriThumbnail"
    }.freeze

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
    def store
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
      mime_type = Marcel::MimeType.for(io, name: "#{@document.id}.tmp")
      io.rewind if io.respond_to?(:rewind)

      media_type, subtype = mime_type.to_s.split("/", 2)
      @metadata["content_type"] = mime_type

      if media_type == "image" && subtype.present?
        @document.sidecar.image.attach(
          io: io,
          filename: "#{@document.id}.#{subtype}",
          content_type: mime_type
        )
        @document.sidecar.image_state.transition_to!(:succeeded, @metadata)
      else
        @document.sidecar.image_state.transition_to!(:placeheld, @metadata)
      end
    end

    def geoserver_credentials
      return unless restricted_wms_layer?

      Settings.PROXY_GEOSERVER_AUTH.to_s.gsub("Basic ", "")
    end

    def geoserver_credentials_valid?
      Settings.PROXY_GEOSERVER_AUTH.to_s.present? &&
        Settings.PROXY_GEOSERVER_AUTH != "Basic base64encodedusername:password"
    end

    def gblsi_thumbnail_field?
      Settings.GBLSI_THUMBNAIL_FIELD.present?
    end

    def gblsi_thumbnail_uri
      if gblsi_thumbnail_field? && @document[Settings.GBLSI_THUMBNAIL_FIELD]
        @document[Settings.GBLSI_THUMBNAIL_FIELD]
      else
        false
      end
    end

    def image_data
      return @image_data if defined?(@image_data)

      @image_data = image_url && remote_image
    end

    def remote_image
      uri = Addressable::URI.parse(image_url)
      unless allowed_uri?(uri)
        @metadata["error"] = "Blocked or invalid image URL"
        @metadata["placeheld"] = true
        return nil
      end

      conn = Faraday.new(url: uri.normalize.to_s) do |f|
        f.response :follow_redirects, limit: 5
        f.options.timeout = timeout
        f.options.open_timeout = timeout
        f.headers["Authorization"] = "Basic #{geoserver_credentials}" if geoserver_credentials
        f.adapter :net_http
      end

      response = conn.get
      unless response.success?
        @metadata["error"] = "HTTP #{response.status}"
        @metadata["placeheld"] = true
        return nil
      end

      if response.body.bytesize > MAX_BODY_BYTES
        @metadata["error"] = "Image exceeds #{MAX_BODY_BYTES} bytes"
        @metadata["placeheld"] = true
        return nil
      end

      response.body
    rescue Faraday::ConnectionFailed
      @metadata["error"] = "Faraday::ConnectionFailed"
      @metadata["placeheld"] = true
      nil
    rescue Faraday::TimeoutError
      @metadata["error"] = "Faraday::TimeoutError"
      @metadata["placeheld"] = true
      nil
    end

    def allowed_uri?(uri)
      return false unless uri && %w[http https].include?(uri.scheme)
      return false if private_or_local_address?(uri)

      true
    end

    def private_or_local_address?(uri)
      host = uri.host.to_s
      return true if host.blank? || host == "localhost" || host.end_with?(".localhost")

      ip = IPAddr.new(host)
      ip.loopback? || ip.private? || ip.link_local?
    rescue IPAddr::InvalidAddressError
      return false if Rails.env.test?

      addr = IPAddr.new(Resolv.getaddress(host))
      addr.loopback? || addr.private? || addr.link_local?
    rescue
      true
    end

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

    def restricted_scanned_map?
      return false unless @document.local_restricted?

      types = Array(@document[resource_type_field]) + Array(@document[resource_class_field])
      types.any? { |value| value.to_s.match?(/image/i) } ||
        @document["layer_geom_type_s"] == "Image"
    end

    def restricted_wms_layer?
      @document.local_restricted? && @document.viewer_protocol == "wms"
    end

    def service_url
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

          adapter = adapter_for(protocol)
          unless adapter
            @metadata["error"] = "Unknown viewer protocol: #{protocol}"
            @metadata["placeheld"] = true
            return nil
          end

          adapter.image_url(@document, image_size)
        end
    end

    def adapter_for(protocol)
      constant_name = ADAPTERS[protocol.to_s]
      return unless constant_name

      constant_name.constantize
    end

    def image_reference
      field = @document.references.reference_field
      return nil if @document[field].nil?

      JSON.parse(@document[field])["http://schema.org/thumbnailUrl"]
    end

    def resource_type_field
      GeoblacklightSidecarImages::FieldMap[:resource_type]
    end

    def resource_class_field
      GeoblacklightSidecarImages::FieldMap[:resource_class]
    end

    def image_size
      1500
    end

    def timeout
      30
    end

    def log_output
      @metadata["state"] = @document.sidecar.image_state.current_state
      @metadata.each do |key, value|
        @logger.tagged(@document.id, key.to_s) { @logger.info value }
      end
    end
  end
end
