# frozen_string_literal: true

require "rails/generators"

class TestAppGenerator < Rails::Generators::Base
  source_root "./spec/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application

  def disable_include_all_helpers
    return unless File.exist?("config/application.rb")

    gsub_file(
      "config/application.rb",
      /(\s*config\.load_defaults\s+\d+\.\d+\n)/,
      "\\1    config.action_controller.include_all_helpers = false\n"
    )
  end

  def add_gems
    gem "blacklight", "~> 7.0"
    gem "geoblacklight", ">= 3.0"

    Bundler.with_unbundled_env do
      run "bundle install"
    end
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)
    generate "blacklight:install", "--devise"
  end

  def run_geoblacklight_generator
    say_status("warning", "GENERATING GBL", :yellow)
    generate "geoblacklight:install", "--force"
  end

  def run_geoblacklight_sidecar_images_generator
    say_status("warning", "GENERATING GBLSI", :yellow)
    generate "geoblacklight_sidecar_images:install"
  end
end
