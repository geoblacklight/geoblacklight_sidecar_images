# frozen_string_literal: true

require "faraday"

module GeoblacklightSidecarImages
  class StoreImageJob < ApplicationJob
    queue_as :gblsci

    retry_on Faraday::TimeoutError, wait: :polynomially_longer, attempts: 5
    retry_on Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: 3
    discard_on Blacklight::Exceptions::RecordNotFound

    def perform(solr_document_id)
      document = Geoblacklight::SolrDocument.find(solr_document_id)

      metadata = {
        "solr_doc_id" => document.id,
        "solr_version" => document.sidecar.version
      }

      document.sidecar.image_state.transition_to!(:queued, metadata)
      GeoblacklightSidecarImages::ImageService.new(document).store
    end
  end
end
