# frozen_string_literal: true

require "spec_helper"
require "base64"

describe GeoblacklightSidecarImages::ImageService do
  let(:png_bytes) do
    Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
  end

  before do
    stub_request(:get, /.*/).to_return(
      status: 200,
      body: png_bytes,
      headers: {"Content-Type" => "image/png"}
    )
  end

  let(:dynamic_map_document) { SolrDocument.new(json_data("esri-dynamic-layer-all-layers")) }
  let(:dynamic_map_imgsvc) { described_class.new(dynamic_map_document) }

  let(:iiif_document) { SolrDocument.new(json_data("umich_iiif_jpg")) }
  let(:iiif_imgsvc) { described_class.new(iiif_document) }

  let(:image_map_document) { SolrDocument.new(json_data("esri-image-map-layer")) }
  let(:image_map_imgsvc) { described_class.new(image_map_document) }

  let(:wms_document) { SolrDocument.new(json_data("actual-polygon1")) }
  let(:wms_imgsvc) { described_class.new(wms_document) }

  let(:thumb_document) { SolrDocument.new(json_data("umn_solr_thumb")) }
  let(:thumb_imgsvc) { described_class.new(thumb_document) }

  let(:tiled_map_document) { SolrDocument.new(json_data("esri-tiled_map_layer")) }
  let(:tiled_map_imgsvc) { described_class.new(tiled_map_document) }

  let(:placeholder_document) { SolrDocument.new(json_data("placeholder")) }
  let(:placeholder_imgsvc) { described_class.new(placeholder_document) }

  describe "#store" do
    it "responds to store" do
      expect(iiif_imgsvc).to respond_to(:store)
    end

    it "stores a Dynamic Map Layer" do
      dynamic_map_imgsvc.store
      expect(dynamic_map_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores a IIIF image" do
      iiif_imgsvc.store
      expect(iiif_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores an Image Map Layer" do
      image_map_imgsvc.store
      expect(image_map_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores a Thumbnail" do
      thumb_imgsvc.store
      expect(thumb_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores a Tiled Map Layer" do
      tiled_map_imgsvc.store
      expect(tiled_map_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "stores a WMS image" do
      wms_imgsvc.store
      expect(wms_imgsvc.document.sidecar.image_state.current_state).to eq("succeeded")
    end

    it "placeholders a doc without an imageservice" do
      placeholder_imgsvc.store
      expect(placeholder_imgsvc.document.sidecar.image_state.current_state).to eq("placeheld")
    end

    it "prioritizes settings thumbnail field" do
      expect(thumb_imgsvc.send(:gblsi_thumbnail_field?)).to be_truthy
    end

    it "returns image_url" do
      expect(thumb_imgsvc.send(:image_url)).to eq "https://cdm16022.contentdm.oclc.org/utils/getthumbnail/collection/p16022coll206/id/133.jpg"
    end

    it "returns no service_url when settings thumbnail field" do
      expect(thumb_imgsvc.send(:service_url)).to be_falsey
    end

    context "when the remote service returns an error status" do
      before do
        stub_request(:get, /.*/).to_return(status: 500, body: "error")
      end

      it "placeholds the image" do
        iiif_imgsvc.store
        expect(iiif_imgsvc.document.sidecar.image_state.current_state).to eq("placeheld")
      end
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
end
