# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'

module GeoblacklightSidecarImages
  class ModelsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('templates', __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Preps engine migrations
       2. Adds SolrDocumentSidecar ActiveRecord model
       3. Adds WmsRewriteConcern
    DESCRIPTION

    # Setup the database migrations
    def copy_migrations
      rake 'geoblacklight_sidecar_images:install:migrations'
    end

    def include_sidecar_solrdocument
      sidecar = <<-"SIDECAR"
        def sidecar
          SolrDocumentSidecar.find_or_create_by!(
            document_id: id,
            document_type: self.class.to_s
          )
        end
      SIDECAR

      inject_into_file 'app/models/solr_document.rb', sidecar, before: /^end/
    end

    def create_solr_document_sidecar
      copy_file(
        'models/solr_document_sidecar.rb',
        'app/models/solr_document_sidecar.rb'
      )
    end

    def create_solr_document_sidecar_image
      copy_file(
        'models/solr_document_sidecar_image.rb',
        'app/models/solr_document_sidecar_image.rb'
      )
    end

    def create_solr_document_sidecar_image_transition
      copy_file(
        'models/solr_document_sidecar_image_transition.rb',
        'app/models/solr_document_sidecar_image_transition.rb'
      )
    end

    def create_solr_document_sidecar_image_state_machine
      copy_file(
        'models/solr_document_sidecar_image_state_machine.rb',
        'app/models/solr_document_sidecar_image_state_machine.rb'
      )
    end

    def create_wms_rewrite_concern
      copy_file(
        'models/concerns/wms_rewrite_concern.rb',
        'app/models/concerns/wms_rewrite_concern.rb'
      )
    end

    def include_wms_rewrite_solrdocument
      inject_into_file(
        'app/models/solr_document.rb',
        after: 'include Geoblacklight::SolrDocument'
      ) do
        "\n include WmsRewriteConcern"
      end
    end
  end
end
