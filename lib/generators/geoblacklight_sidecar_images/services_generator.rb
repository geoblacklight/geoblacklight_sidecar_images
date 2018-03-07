# frozen_string_literal: true

require 'rails/generators'

module GeoblacklightSidecarImages
  class ServicesGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Creates an app/services directory
       2. Creates service models within the app/services directory
    DESCRIPTION

    def create_services
      directory 'services', 'app/services'
    end
  end
end
