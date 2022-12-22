require 'rails/generators'

module GeoblacklightSidecarImages
  class Install < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    desc 'Install GeoblacklightSidecarImages'

    def add_settings_vars
      inject_into_file 'config/settings.yml', after: "INSTITUTION: 'Stanford'\n" do
"INSTITUTION_LOCAL_NAME: 'Princeton'
INSTITUTION_GEOSERVER_URL: 'https://geoserver.princeton.edu'
PROXY_GEOSERVER_URL: 'http://localhost:3000'
PROXY_GEOSERVER_AUTH: 'Basic base64encodedusername:password'
GBLSI_THUMBNAIL_FIELD: 'thumbnail_path_ss'"
      end
    end

    def generate_gblsci_assets
      copy_file 'gblsci.scss', 'app/assets/stylesheets/gblsci.scss'
    end

    def generate_gblsci_example_docs
      generate 'geoblacklight_sidecar_images:example_docs'
    end

    def generate_gblsci_jobs
      generate 'geoblacklight_sidecar_images:jobs'
    end

    def generate_gblsci_models
      generate 'geoblacklight_sidecar_images:models'
    end

    def generate_gblsci_views
      generate 'geoblacklight_sidecar_images:views'
    end

    def generate_action_storage
      rake 'active_storage:install'
    end

    def generate_gblsci_config
      generate 'geoblacklight_sidecar_images:config'
    end

    def bundle_install
      Bundler.with_unbundled_env do
        run 'bundle install'
      end
    end
  end
end
