# frozen_string_literal: true

require 'rails/generators'

module GeoblacklightSidecarImages
  class JobsGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__) 

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies jobs files to host app/jobs
       2. Configures a default development environment queue adapter
    DESCRIPTION

    def create_store_image_jobs
      copy_file 'jobs/store_image_job.rb', 'app/jobs/store_image_job.rb'
    end

    def config_development_jobs_queue_adapter
      job_config = <<-"JOBS"
        config.active_job.queue_adapter = :inline
      JOBS

      inject_into_file 'config/environments/development.rb', job_config, before: /^end/
    end
  end
end
