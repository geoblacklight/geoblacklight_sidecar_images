# frozen_string_literal: true

require 'rails/generators'

module GeoblacklightSidecarImages
  class AssetsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies asset image files to host app/assets/images
    DESCRIPTION

    def create_images_assets
      thumbs = [
        'thumbnail-image.png',
        'thumbnail-line.png',
        'thumbnail-mixed.png',
        'thumbnail-multipoint.png',
        'thumbnail-paper-map.png',
        'thumbnail-point.png',
        'thumbnail-polygon.png',
        'thumbnail-raster.png'
      ]

      thumbs.each do |tbnl|
        copy_file("assets/images/#{tbnl}", "app/assets/images/#{tbnl}")
      end
    end
  end
end
