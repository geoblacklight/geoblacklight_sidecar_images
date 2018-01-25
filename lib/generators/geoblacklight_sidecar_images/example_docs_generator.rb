# frozen_string_literal: true
require 'rails/generators'

module GeoblacklightSidecarImages
  class ExampleDocsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../spec/fixtures/', __FILE__)

    desc <<-EOS
      This generator makes the following changes to your application:
       1. Copies the dir of example solr doc files to host app/solr/geoblacklight/example_docs
    EOS

    def create_services
      directory 'solr_documents', 'solr/geoblacklight/example_docs'
    end
  end
end
