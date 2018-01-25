require 'rails/generators'

module GeoblacklightSidecarImages
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Install GeoblacklightSidecarImages'

    def add_settings_vars
      settings = <<-"SETTINGS"
        INSTITUTION_LOCAL_NAME: <%= ENV['INSTITUTION_LOCAL_NAME'] || "Princeton" %>
        INSTITUTION_GEOSERVER_URL: <%= ENV['INSTITUTION_GEOSERVER_URL'] || "https://geoserver.princeton.edu" %>
        PROXY_GEOSERVER_URL: <%= ENV['PROXY_GEOSERVER_URL'] || "http://localhost:3000" %>
        PROXY_GEOSERVER_AUTH: <%= ENV['PROXY_GEOSERVER_AUTH'] || "Basic base64encodedusername:password" %>
      SETTINGS

      inject_into_file 'config/settings.yml', settings, before: /^end/
    end

    def add_carrierwave_require
      inject_into_file 'config/application.rb', after: "require 'rails/all'" do
        "\n  require 'carrierwave'"
      end
    end

    def generate_geoblacklight_assets
      generate 'geoblacklight_sidecar_images:assets'
    end

    def generate_geoblacklight_example_docs
      generate 'geoblacklight_sidecar_images:example_docs'
    end

    def generate_geoblacklight_jobs
      generate 'geoblacklight_sidecar_images:jobs'
    end

    def generate_geoblacklight_models
      generate 'geoblacklight_sidecar_images:models'
    end

    def generate_geoblacklight_services
      generate 'geoblacklight_sidecar_images:services'
    end

    def generate_geoblacklight_uploaders
      generate 'geoblacklight_sidecar_images:uploaders'
    end

    def bundle_install
      Bundler.with_clean_env do
        run 'bundle install'
      end
    end
  end
end
