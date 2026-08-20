# frozen_string_literal: true

require "spec_helper"

describe GeoblacklightSidecarImages::ImageService::Wms do
  let(:document) { SolrDocument.new(json_data("actual-polygon1")) }

  it "builds a GeoServer reflect URL from the WXS identifier" do
    url = described_class.image_url(document, 1500)
    expect(url).to include("/reflect?")
    expect(url).to include("LAYERS=sde:GISPORTAL.GISOWNER01.CAMBRIDGEGRID100_04")
    expect(url).to include("WIDTH=1500")
  end
end

describe GeoblacklightSidecarImages::ImageService::EsriThumbnail do
  let(:document) { SolrDocument.new(json_data("esri-tiled_map_layer")) }

  it "appends the ArcGIS thumbnail path" do
    expect(described_class.image_url(document, 100)).to end_with("/info/thumbnail/thumbnail.png")
  end
end

describe GeoblacklightSidecarImages::ImageService::Iiif do
  let(:document) { SolrDocument.new(json_data("umich_iiif_jpg")) }

  it "builds an IIIF image API thumbnail URL" do
    expect(described_class.image_url(document, 1500)).to include("full/1500,/0/default.jpg")
  end
end
