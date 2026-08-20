# frozen_string_literal: true

require "rails/generators"

module GeoblacklightSidecarImages
  class ModelsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator copies engine migrations into the host application.
      SolrDocument#sidecar is provided by GeoblacklightSidecarImages::SolrDocumentBehavior.
    DESCRIPTION

    def copy_migrations
      rake "geoblacklight_sidecar_images:install:migrations"
    end
  end
end
