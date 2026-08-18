# frozen_string_literal: true

require "spec_helper"
require "rake"

describe "geoblacklight_sidecar_images_tasks.rake" do
  include ActiveJob::TestHelper

  before do
    Rails.application.load_tasks
  end

  after do
    Rake::Task.tasks.each(&:reenable)
  end

  describe "gblsci:images:harvest_doc_id" do
    it "enqueues background job to harvest image" do
      ENV["DOC_ID"] = "princeton-02870w62c"
      Rake::Task["gblsci:images:harvest_doc_id"].invoke
      expect(enqueued_jobs.size).to eq(1)
    end
  end

  describe "gblsci:images:harvest_purge_all" do
    it "aborts without CONFIRM=1" do
      ENV.delete("CONFIRM")
      expect {
        Rake::Task["gblsci:images:harvest_purge_all"].invoke
      }.to raise_error(SystemExit).and output(/CONFIRM=1/).to_stderr
    end
  end
end
