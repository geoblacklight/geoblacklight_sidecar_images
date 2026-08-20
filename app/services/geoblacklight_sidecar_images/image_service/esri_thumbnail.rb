# frozen_string_literal: true

module GeoblacklightSidecarImages
  class ImageService
    module EsriThumbnail
      def self.image_url(document, _size)
        "#{document.viewer_endpoint}/info/thumbnail/thumbnail.png"
      end
    end
  end
end
