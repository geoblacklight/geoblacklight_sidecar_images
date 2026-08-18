# frozen_string_literal: true

module GeoblacklightSidecarImages
  class ImageService
    module Wms
      def self.image_url(document, size)
        endpoint = document.viewer_endpoint.to_s
        proxy = Settings.PROXY_GEOSERVER_URL.to_s
        institution = Settings.INSTITUTION_GEOSERVER_URL.to_s
        if proxy.present? && institution.present?
          endpoint = endpoint.gsub(proxy, institution)
        end

        layer = document[wxs_identifier_field] || document["gbl_wxsIdentifier_s"]
        "#{endpoint}/reflect?" \
          "&FORMAT=image%2Fpng" \
          "&TRANSPARENT=TRUE" \
          "&LAYERS=#{layer}" \
          "&WIDTH=#{size}" \
          "&HEIGHT=#{size}"
      end

      def self.wxs_identifier_field
        Settings.FIELDS.WXS_IDENTIFIER || "gbl_wxsIdentifier_s"
      end
    end
  end
end
