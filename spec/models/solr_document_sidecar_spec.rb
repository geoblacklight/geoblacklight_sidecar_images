# frozen_string_literal: true

require "spec_helper"

describe SolrDocumentSidecar do
  let(:document) { SolrDocument.new(document_attributes) }

  describe "#sidecar" do
    let(:document_attributes) { json_data("umn_iiif_jpg") }

    it "responds to image method" do
      expect(document.sidecar).to respond_to :image
    end
  end
end
