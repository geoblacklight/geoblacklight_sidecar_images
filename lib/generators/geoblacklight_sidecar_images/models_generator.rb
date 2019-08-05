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
          # Find or create, and set version
          sidecar = SolrDocumentSidecar.where(
            document_id: id,
            document_type: self.class.to_s
          ).first_or_create do |sc|
            sc.version = self._source["_version_"]
          end

          sidecar.version = self._source["_version_"]
          sidecar.save

          sidecar
        end
      SIDECAR

      inject_into_file 'app/models/solr_document.rb', sidecar, before: /^end/
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
