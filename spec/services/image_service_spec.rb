# frozen_string_literal: true

require 'rails_helper'

describe ImageService do
  let(:iiif_document) { SolrDocument.new(json_data('umich_iiif_jpg')) }
  let(:iiif_imgsvc) { ImageService.new(iiif_document) }
  let(:wms_document) { SolrDocument.new(json_data('public_polygon_mit')) }
  let(:wms_imgsvc) { ImageService.new(wms_document) }
  let(:thumb_document) { SolrDocument.new(json_data('umn_solr_thumb')) }
  let(:thumb_imgsvc) { ImageService.new(thumb_document) }

  describe '#store' do
    it 'should respond to store' do
      expect(iiif_imgsvc).to respond_to(:store)
    end

    it 'should prioritize settings thumbnail field' do
      expect(thumb_imgsvc.send(:gblsi_thumbnail_field?)).to be_truthy
      expect(thumb_imgsvc.send(:image_url)).to eq 'https://umedia.lib.umn.edu/sites/default/files/imagecache/square300/reference/562/image/jpeg/1089695.jpg'
    end

    it 'should choose references if no settings thumbnail field value' do
      expect(wms_imgsvc.send(:gblsi_thumbnail_field?)).to be_truthy
      expect(wms_imgsvc.send(:image_url)).to include 'wms'
    end
  end

  context '#iiif' do
    describe '#private' do
      it 'should determine :image_url' do
        expect(iiif_imgsvc.send(:image_url)).to be_kind_of String
        expect(URI(iiif_imgsvc.send(:image_url))).to be_kind_of URI
      end

      it 'should determine :remote_content_type' do
        expect(iiif_imgsvc.send(:remote_content_type)).to eq 'image/jpeg'
      end

      it 'should determine :image_extension' do
        expect(iiif_imgsvc.send(:image_extension)).to eq '.jpeg'
      end
    end
  end
end
