# frozen_string_literal: true

require 'rails_helper'

describe ImageService do
  let(:iiif_document) { SolrDocument.new(json_data('umn_iiif_jpg')) }
  let(:iiif_imgsvc) { ImageService.new(iiif_document) }
  let(:wms_document) { SolrDocument.new(json_data('public_polygon_mit')) }
  let(:wms_imgsvc) { ImageService.new(iiif_document) }

  describe '#store' do
    it 'should respond to store' do
      expect(iiif_imgsvc).to respond_to(:store)
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
