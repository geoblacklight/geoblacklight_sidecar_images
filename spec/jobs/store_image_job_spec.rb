# frozen_string_literal: true

require "spec_helper"

describe GeoblacklightSidecarImages::StoreImageJob, type: :job do
  let(:document) { SolrDocument.new(document_attributes) }

  describe "#perform_later" do
    let(:document_attributes) { json_data("umn_iiif_jpg") }

    it "enqueues a harvest job on the gblsci queue" do
      expect {
        described_class.perform_later(document.id)
      }.to have_enqueued_job(described_class).on_queue("gblsci")
    end
  end
end
