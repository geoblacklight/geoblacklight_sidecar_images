# frozen_string_literal: true

require "spec_helper"

describe GeoblacklightSidecarImages::ApplicationHelper, type: :helper do
  let(:document) { SolrDocument.new(json_data("umn_iiif_jpg")) }

  around do |example|
    original = Settings.try(:GBLSI_OGM_API_URL)
    example.run
    Settings.GBLSI_OGM_API_URL = original
  end

  describe "#sidecar_thumbnail_tag" do
    it "renders an OGM API img without creating a sidecar" do
      Settings.GBLSI_OGM_API_URL = "https://ogm.geo4lib.app/api/v1"

      html = nil
      expect {
        html = helper.sidecar_thumbnail_tag(document)
      }.not_to change(SolrDocumentSidecar, :count)

      expect(html).to include("https://ogm.geo4lib.app/api/v1/resources/#{document.id}/thumbnail")
      expect(html).to include("alt=\"\"")
    end

    it "does not hit the OGM API when the setting is blank" do
      Settings.GBLSI_OGM_API_URL = ""
      expect(helper.sidecar_thumbnail_tag(document)).to be_nil
    end
  end
end
