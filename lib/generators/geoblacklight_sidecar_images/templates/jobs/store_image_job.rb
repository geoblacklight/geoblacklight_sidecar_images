# frozen_string_literal: true

class StoreImageJob < ApplicationJob
  queue_as :default

  def perform(solr_document_id)
    cat = CatalogController.new
    _response, document = cat.fetch(solr_document_id)

    metadata = {}
    metadata['solr_doc_id'] = document.id
    metadata['solr_version'] = document.sidecar.version

    document.sidecar.image_state.transition_to!(:queued, metadata)
    ImageService.new(document).store
  end
end
