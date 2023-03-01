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

  # zsh - bundle exec rake gblsci:images:harvest_doc_id\['stanford-cz128vq0535'\]
  describe "gblsci:images:harvest_doc_id['stanford-cz128vq0535']" do
    before do
      Rails.application.load_tasks
    end

    it "tasks can be invoked" do
      # Enqueues job
      ENV["DOC_ID"] = "princeton-sx61dn82p"
      Rake::Task["gblsci:images:harvest_doc_id"].invoke
      expect(enqueued_jobs.size).to eq(1)
      
      perform_enqueued_jobs

      sd = SolrDocument.find(ENV["DOC_ID"])
      expect(sd.sidecar.image?).to eq(true)
    end
  end
end
