# frozen_string_literal: true

require "rails/generators"

module GeoblacklightSidecarImages
  class HelpersGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Creates an app/helpers/blacklight directory
    DESCRIPTION

    def create_views
      copy_file(
        "helpers/blacklight/layout_helper_behavior.rb",
        "app/helpers/blacklight/layout_helper_behavior.rb"
      )
    end
  end
end
