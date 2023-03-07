# frozen_string_literal: true

require "rails_helper"

describe GeoblacklightSidecarImages::ImageService do
  # Dynamic Map Layer
  let(:dynamic_map_document) { SolrDocument.new(json_data("esri-dynamic-layer-all-layers")) }
  let(:dynamic_map_imgsvc) { described_class.new(dynamic_map_document) }

  # IIIF
  let(:iiif_document) { SolrDocument.new(json_data("umich_iiif_jpg")) }
  let(:iiif_imgsvc) { described_class.new(iiif_document) }

  # Image Map Layer
  let(:image_map_document) { SolrDocument.new(json_data("esri-image-map-layer")) }
  let(:image_map_imgsvc) { described_class.new(image_map_document) }

  # WMS
  let(:wms_document) { SolrDocument.new(json_data("actual-polygon1")) }
  let(:wms_imgsvc) { described_class.new(wms_document) }

  # Thumbnail
  let(:thumb_document) { SolrDocument.new(json_data("umn_solr_thumb")) }
  let(:thumb_imgsvc) { described_class.new(thumb_document) }

  # Tiled Map Layer
  let(:tiled_map_document) { SolrDocument.new(json_data("esri-tiled_map_layer")) }
  let(:tiled_map_imgsvc) { described_class.new(tiled_map_document) }

  # Placeholder Image
  let(:placeholder_document) { SolrDocument.new(json_data("placeholder")) }
  let(:placeholder_imgsvc) { described_class.new(placeholder_document) }

  describe "#store" do
    it "responds to store" do
      expect(iiif_imgsvc).to respond_to(:store)
    end

    it "stores a Dynamic Map Layer" do
      # Doc: 90f14ff4-1359-4beb-b931-5cb41d20ab90
      dynamic_map_imgsvc.store
      expect(dynamic_map_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores a IIIF image" do
      # Doc: 3ffb1f2e-d617-4361-bc2b-49d9ad270cad
      iiif_imgsvc.store
      expect(iiif_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores an Image Map Layer" do
      # Doc: 32653ed6-8d83-4692-8a06-bf13ffe2c018
      image_map_imgsvc.store
      expect(image_map_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores a Thumbnail" do
      thumb_imgsvc.store
      expect(thumb_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores a Tiled Map Layer" do
      # Doc: esri-tiled-map-layer
      tiled_map_imgsvc.store
      expect(tiled_map_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores a WMS image" do
      # Doc: tufts-cambridgegrid100-04
      wms_imgsvc.store
      expect(wms_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "placeholders a doc without an imageservice" do
      # Doc: mit-001145244
      placeholder_imgsvc.store
      expect(placeholder_imgsvc.document.sidecar.image_state.current_state).to eq("placeheld")
    end

    it "prioritizes settings thumbnail field" do
      expect(thumb_imgsvc.send(:gblsi_thumbnail_field?)).to be_truthy
    end

    it "returns image_url" do
      expect(thumb_imgsvc.send(:image_url)).to eq "https://cdm16022.contentdm.oclc.org/utils/getthumbnail/collection/p16022coll206/id/133.jpg"
    end

    it "returns references if no settings thumbnail field value" do
      expect(wms_imgsvc.send(:gblsi_thumbnail_field?)).to be_truthy
    end

    it "returns references without a settings thumbnail field value" do
      skip "MIT fixture is not working."
      expect(wms_imgsvc.send(:image_url)).to include "wms"
    end

    it "returns no service_url when settings thumbnail field" do
      expect(thumb_imgsvc.send(:service_url)).to be_falsey
    end
  end

  context "when #iiif" do
    describe "#private" do
      it "determines :image_url" do
        expect(iiif_imgsvc.send(:image_url)).to be_kind_of String
      end

      it "returns a URI" do
        expect(URI(iiif_imgsvc.send(:image_url))).to be_kind_of URI
      end
    end
  end

  # Minnesota-urn-0f7ae38b-4bf2-4e03-a32b-e87f245ccb03
  # => attachable? should be false
end
