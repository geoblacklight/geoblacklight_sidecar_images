# frozen_string_literal: true

require 'rails/generators'

module GeoblacklightSidecarImages
  class UploadersGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Creates an app/uploaders directory
       2. Creates uploader models within the app/uploaders directory
    DESCRIPTION

    def create_image_uploader
      directory 'uploaders', 'app/uploaders'
    end
  end
end
