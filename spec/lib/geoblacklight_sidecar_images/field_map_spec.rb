# frozen_string_literal: true

require "spec_helper"

describe GeoblacklightSidecarImages::FieldMap do
  it "resolves Aardvark field names when Settings.FIELDS is absent" do
    allow(described_class).to receive(:from_gbl_configuration).and_return(nil)
    allow(Settings).to receive(:try).and_call_original
    allow(Settings).to receive(:try).with(:FIELDS).and_return(nil)

    expect(described_class[:wxs_identifier]).to eq("gbl_wxsIdentifier_s")
    expect(described_class[:title]).to eq("dct_title_s")
    expect(described_class[:provider]).to eq("schema_provider_s")
  end

  it "reads GBL 4/5 Settings.FIELDS when present" do
    allow(described_class).to receive(:from_gbl_configuration).and_return(nil)
    allow(Settings).to receive(:try).and_call_original
    allow(Settings).to receive(:try).with(:FIELDS).and_return(
      {"WXS_IDENTIFIER" => "custom_wxs_s"}
    )

    expect(described_class[:wxs_identifier]).to eq("custom_wxs_s")
  end
end
