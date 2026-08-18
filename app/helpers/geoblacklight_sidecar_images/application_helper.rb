# frozen_string_literal: true

module GeoblacklightSidecarImages
  module ApplicationHelper
    def sidecar_thumbnail_tag(document, size: [200, 200], **options)
      options = {alt: "", role: "presentation"}.merge(options)

      ogm_url = document.try(:ogm_thumbnail_url)
      return image_tag(ogm_url, options) if ogm_url.present?

      sidecar = document.sidecar
      return unless sidecar.image.attached?

      if sidecar.image.variable?
        image_tag sidecar.image.variant(resize_to_fit: size), options
      else
        image_tag sidecar.image, options
      end
    end
  end
end
