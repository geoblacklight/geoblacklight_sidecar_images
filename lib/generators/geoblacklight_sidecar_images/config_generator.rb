# frozen_string_literal: true

require "rails/generators"

module GeoblacklightSidecarImages
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies config files to host config
    DESCRIPTION

    def set_active_storage_processor
      app_config = <<-"APP"
      
        config.active_storage.variant_processor = :mini_magick
      APP

      inject_into_file "config/application.rb", app_config, after: "config.generators.system_tests = nil"
    end

    def create_statesman_initializer
      copy_file "config/initializers/statesman.rb", "config/initializers/statesman.rb"
    end
  end
end
