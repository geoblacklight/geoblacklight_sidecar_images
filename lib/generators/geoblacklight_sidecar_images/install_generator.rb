# frozen_string_literal: true

require "rails/generators"

module GeoblacklightSidecarImages
  class Install < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    class_option :skip_views, type: :boolean, default: false,
      desc: "Skip copying catalog result views"
    class_option :skip_assets, type: :boolean, default: false,
      desc: "Skip injecting stylesheet imports"

    desc "Install GeoblacklightSidecarImages"

    def add_settings_vars
      settings_path = "config/settings.yml"
      unless File.exist?(settings_path)
        say_status :skip, "config/settings.yml not found", :yellow
        return
      end

      contents = File.read(settings_path)

      unless contents.include?("GBLSI_THUMBNAIL_FIELD")
        append_to_file settings_path, <<~YAML

          # GeoBlacklight Sidecar Images
          INSTITUTION_LOCAL_NAME: ''
          INSTITUTION_GEOSERVER_URL: ''
          PROXY_GEOSERVER_URL: ''
          PROXY_GEOSERVER_AUTH: 'Basic base64encodedusername:password'
          GBLSI_THUMBNAIL_FIELD: 'thumbnail_path_ss'
          # Optional: https://ogm.geo4lib.app/api/v1 (leave blank to harvest locally)
          GBLSI_OGM_API_URL: ''
        YAML
      end

      return if File.read(settings_path).include?("GBLSI_OGM_API_URL")

      append_to_file settings_path, <<~YAML

        # OpenGeoMetadata API thumbnails (optional). When set, views render
        # OGM thumbnail URLs and skip sidecar harvest / Active Storage.
        # Example: https://ogm.geo4lib.app/api/v1
        GBLSI_OGM_API_URL: ''
      YAML
    end

    def generate_gblsci_assets
      return if options[:skip_assets]

      stylesheet = %w[
        app/assets/stylesheets/application.scss
        app/assets/stylesheets/application.css
      ].find { |path| File.exist?(path) }

      unless stylesheet
        say_status :skip, "No application stylesheet found; import geoblacklight_sidecar_images/gblsci if needed", :yellow
        return
      end

      contents = File.read(stylesheet)
      return if contents.include?("geoblacklight_sidecar_images/gblsci")

      if contents.include?("@import 'geoblacklight';")
        inject_into_file stylesheet, after: "@import 'geoblacklight';\n" do
          "@import 'geoblacklight_sidecar_images/gblsci';\n"
        end
      else
        append_to_file stylesheet, "\n@import 'geoblacklight_sidecar_images/gblsci';\n"
      end
    end

    def generate_gblsci_example_docs
      generate "geoblacklight_sidecar_images:example_docs"
    end

    def generate_gblsci_jobs
      generate "geoblacklight_sidecar_images:jobs"
    end

    def generate_gblsci_models
      generate "geoblacklight_sidecar_images:models"
    end

    def generate_gblsci_views
      if options[:skip_views]
        say_status :skip, "catalog views", :yellow
        return
      end

      generate "geoblacklight_sidecar_images:views"
    end

    def generate_action_storage
      rake "active_storage:install"
    end

    def generate_gblsci_config
      generate "geoblacklight_sidecar_images:config"
    end

    def bundle_install
      Bundler.with_unbundled_env do
        run "bundle install"
      end
    end
  end
end
