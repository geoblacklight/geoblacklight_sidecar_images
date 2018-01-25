require 'rails/generators'

module GeoblacklightSidecarImages
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Install GeoblacklightSidecarImages'

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
