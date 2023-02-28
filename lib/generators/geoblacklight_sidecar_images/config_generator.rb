# frozen_string_literal: true

require "rails/generators"

module GeoblacklightSidecarImages
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies config files to host config
    DESCRIPTION

    def create_store_image_jobs
      copy_file "config/initializers/statesman.rb", "config/initializers/statesman.rb"
    end
  end
end
