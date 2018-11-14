# frozen_string_literal: true

require 'rails_helper'

describe ImageService do
  let(:iiif_document) { SolrDocument.new(json_data('umich_iiif_jpg')) }
  let(:iiif_imgsvc) { described_class.new(iiif_document) }
  let(:wms_document) { SolrDocument.new(json_data('public_polygon_mit')) }
  let(:wms_imgsvc) { described_class.new(wms_document) }
  let(:thumb_document) { SolrDocument.new(json_data('umn_solr_thumb')) }
  let(:thumb_imgsvc) { described_class.new(thumb_document) }

  # @TODO: bdcbcd3e-f6db-4ee4-b7b7-d75fe35f1d92 - Michigan State - thumbnail_path_ss

  describe '#store' do
    it 'responds to store' do
      expect(iiif_imgsvc).to respond_to(:store)
    end

    it 'prioritizes settings thumbnail field' do
      expect(thumb_imgsvc.send(:gblsi_thumbnail_field?)).to be_truthy
    end

    it 'returns image_url' do
      expect(thumb_imgsvc.send(:image_url)).to eq 'https://umedia.lib.umn.edu/sites/default/files/imagecache/square300/reference/562/image/jpeg/1089695.jpg'
    end

    it 'returns references if no settings thumbnail field value' do
      expect(wms_imgsvc.send(:gblsi_thumbnail_field?)).to be_truthy
    end

    it 'returns references without a settings thumbnail field value' do
      expect(wms_imgsvc.send(:image_url)).to include 'wms'
    end
  end

  context 'when #iiif' do
    describe '#private' do
      it 'determines :image_url' do
        expect(iiif_imgsvc.send(:image_url)).to be_kind_of String
      end

      it 'returns a URI' do
        expect(URI(iiif_imgsvc.send(:image_url))).to be_kind_of URI
      end
    end
  end

  # Minnesota-urn-0f7ae38b-4bf2-4e03-a32b-e87f245ccb03
  # => attachable? should be false
end
