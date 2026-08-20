# frozen_string_literal: true

require "addressable/uri"

module GeoblacklightSidecarImages
  # Direct OpenGeoMetadata API thumbnail URLs. When GBLSI_OGM_API_URL is set,
  # views can render these without harvesting into Active Storage or the
  # sidecar state machine.
  module OgmThumbnail
    module_function

    def enabled?
      base_url.present?
    end

    def url_for(document)
      return unless enabled?

      id = document.respond_to?(:id) ? document.id : document
      return if id.blank?

      "#{base_url}/resources/#{encode_id(id)}/thumbnail"
    end

    def base_url
      return unless defined?(Settings)

      Settings.try(:GBLSI_OGM_API_URL).to_s.strip.chomp("/")
    end

    def encode_id(id)
      Addressable::URI.encode_component(id.to_s, Addressable::URI::CharacterClasses::UNRESERVED)
    end
  end
end
