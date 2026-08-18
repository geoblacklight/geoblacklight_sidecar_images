# frozen_string_literal: true

module GeoblacklightSidecarImages
  module ApplicationHelper
    def sidecar_thumbnail_tag(document, size: [200, 200], **options)
      sidecar = document.sidecar
      return unless sidecar.image.attached?

      options = {alt: "", role: "presentation"}.merge(options)

      if sidecar.image.variable?
        image_tag sidecar.image.variant(resize_to_fit: size), options
      else
        image_tag sidecar.image, options
      end
    end
  end
end
