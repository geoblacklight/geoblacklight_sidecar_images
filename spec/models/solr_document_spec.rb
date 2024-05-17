# frozen_string_literal: true

require "spec_helper"

describe Geoblacklight::SolrDocument do
  let(:document) { SolrDocument.new(document_attributes) }

  describe "#sidecar" do
    let(:document_attributes) { json_data("umn_iiif_jpg") }

    it "responds to sidecar method" do
      expect(document).to respond_to :sidecar
    end

    it "responds with SolrDocumentSidecar" do
      expect(document.sidecar).to be_kind_of SolrDocumentSidecar
    end
  end
end
