# frozen_string_literal: true

require "spec_helper"

describe SolrDocumentSidecar do
  let(:document) { SolrDocument.new(document_attributes) }

  describe "#sidecar" do
    let(:document_attributes) { json_data("umn_iiif_jpg") }

    it "responds to image method" do
      expect(document.sidecar).to respond_to :image
    end

    it "creates a sidecar only once" do
      expect { document.sidecar }.to change(SolrDocumentSidecar, :count).by(1)
      expect { document.sidecar }.not_to change(SolrDocumentSidecar, :count)
    end

    it "returns an image url only when attached" do
      expect(document.sidecar.image_url).to be_nil
    end
  end
end
