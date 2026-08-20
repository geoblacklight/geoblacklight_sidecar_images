# frozen_string_literal: true

require "rails/generators"

class TestAppGenerator < Rails::Generators::Base
  source_root "./spec/test_app_templates"

  def disable_include_all_helpers
    return unless File.exist?("config/application.rb")

    gsub_file(
      "config/application.rb",
      /(\s*config\.load_defaults\s+\d+\.\d+\n)/,
      "\\1    config.action_controller.include_all_helpers = false\n"
    )
  end

  def add_gems
    gem "geoblacklight", geoblacklight_constraint

    Bundler.with_unbundled_env do
      run "bundle config set --local specific_platform true"
      run "bundle config set --local force_ruby_platform false"
      run "bundle lock --add-platform #{Gem::Platform.local}"
      run "bundle install"
    end
  end

  def ensure_asset_entrypoints
    unless File.exist?("config/importmap.rb")
      create_file "config/importmap.rb", <<~RUBY
        pin "application"
        pin "bootstrap", to: "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.js"
        pin "@popperjs/core", to: "https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"
      RUBY
    end

    unless File.exist?("app/javascript/application.js")
      create_file "app/javascript/application.js", <<~JS
        import "blacklight-frontend";
      JS
    end

    unless File.exist?("app/assets/stylesheets/application.bootstrap.scss")
      create_file "app/assets/stylesheets/application.bootstrap.scss", <<~SCSS
        @import 'bootstrap/scss/bootstrap';
      SCSS
    end

    if File.exist?("package.json")
      gsub_file "package.json", /"scripts"\s*:\s*\{/, '"scripts": { "build:css": "true",'
    else
      create_file "package.json", <<~JSON
        { "scripts": { "build:css": "true" } }
      JSON
    end
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)
    args = ["--devise"]
    args << "--skip-solr" unless geoblacklight_4?
    generate "blacklight:install", *args
  end

  def run_geoblacklight_generator
    say_status("warning", "GENERATING GBL", :yellow)
    args = ["--force"]
    args << "--test" unless geoblacklight_4?
    generate "geoblacklight:install", *args
  end

  def run_geoblacklight_sidecar_images_generator
    say_status("warning", "GENERATING GBLSI", :yellow)
    generate "geoblacklight_sidecar_images:install", "--force", "--skip-views"
  end

  private

  def geoblacklight_constraint
    ENV.fetch("GEOBLACKLIGHT_VERSION", ">= 4.0")
  end

  def geoblacklight_4?
    version = ENV["GEOBLACKLIGHT_VERSION"].to_s
    version.match?(/[~>=\s]*4[.\s]/) || version.start_with?("4")
  end
end
