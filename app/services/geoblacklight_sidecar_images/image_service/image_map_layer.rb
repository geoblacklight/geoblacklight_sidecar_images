# frozen_string_literal: true

module GeoblacklightSidecarImages
  class ImageService
    module ImageMapLayer
      def self.image_url(document, size)
        EsriThumbnail.image_url(document, size)
      end
    end
  end
end
