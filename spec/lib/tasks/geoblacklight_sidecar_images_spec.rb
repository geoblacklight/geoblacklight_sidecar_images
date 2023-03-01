# frozen_string_literal: true

require "rails_helper"
require "spec_helper"
require "rake"

describe "geoblacklight_sidecar_images_tasks.rake" do
  include ActiveJob::TestHelper

  # @TODO
  # gblsci:sample_data:seed
  # gblsci:images:harvest_all
  # gblsci:images:harvest_states
  # gblsci:images:harvest_retry
  # gblsci:images:harvest_report
  # gblsci:images:harvest_purge_all
  # gblsci:images:harvest_purge_orphans
  # gblsci:images:harvest_destroy_batch
  # gblsci:images:harvest_failed_state_inspect

  # DOC_ID='stanford-cz128vq0535' bundle exec rake gblsci:images:harvest_doc_id
  describe "gblsci:images:harvest_doc_id" do
    before do
      Rails.application.load_tasks
    end

    it "enqueues background job to harvest image" do
      ENV["DOC_ID"] = "princeton-02870w62c"
      Rake::Task["gblsci:images:harvest_doc_id"].invoke
      expect(enqueued_jobs.size).to eq(1)
    end
  end
end
