# frozen_string_literal: true

require 'rails_helper'

describe StoreImageJob, type: :job do
  let(:document) { SolrDocument.new(document_attributes) }

  describe '#perform_later' do
    let(:document_attributes) { json_data('umn_iiif_jpg') }

    it 'stores an image' do
      ActiveJob::Base.queue_adapter = :test
      expect { StoreImageJob.perform_later(document.id) }.to have_enqueued_job(StoreImageJob)
    end
  end
end
