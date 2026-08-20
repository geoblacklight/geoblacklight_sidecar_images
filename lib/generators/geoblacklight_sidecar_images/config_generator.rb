# frozen_string_literal: true

require "rails/generators"

module GeoblacklightSidecarImages
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator copies the Statesman initializer into the host application.
    DESCRIPTION

    def create_statesman_initializer
      copy_file "config/initializers/statesman.rb", "config/initializers/statesman.rb"
    end
  end
end
