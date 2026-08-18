# frozen_string_literal: true

require "spec_helper"

describe GeoblacklightSidecarImages::OgmThumbnail do
  around do |example|
    original = Settings.try(:GBLSI_OGM_API_URL)
    example.run
    Settings.GBLSI_OGM_API_URL = original
  end

  describe ".url_for" do
    let(:document) { SolrDocument.new(json_data("umn_iiif_jpg")) }

    it "is nil when the API URL is blank" do
      Settings.GBLSI_OGM_API_URL = ""
      expect(described_class.url_for(document)).to be_nil
    end

    it "builds a thumbnail URL from the document id" do
      Settings.GBLSI_OGM_API_URL = "https://ogm.geo4lib.app/api/v1"
      expect(described_class.url_for(document)).to eq(
        "https://ogm.geo4lib.app/api/v1/resources/#{document.id}/thumbnail"
      )
    end
  end
end
