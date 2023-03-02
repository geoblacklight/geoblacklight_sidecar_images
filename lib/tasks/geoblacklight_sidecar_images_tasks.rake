require "csv"

namespace :gblsci do
  namespace :sample_data do
    desc "Ingests a directory of geoblacklight.json files"
    task seed: :environment do
      Dir.glob(File.join(Rails.root, "solr", "geoblacklight", "example_docs", "**", "*.json")).each do |fn|
        puts "Ingesting #{fn}"
        begin
          Blacklight.default_index.connection.add(JSON.parse(File.read(fn)))
        rescue => e
          puts "Failed to ingest #{fn}: #{e.inspect}"
        end
      end
      puts "Committing changes to Solr"
      Blacklight.default_index.connection.commit
    end
  end

  namespace :images do
    desc "Harvest image for specific document"
    task harvest_doc_id: :environment do
      GeoblacklightSidecarImages::StoreImageJob.perform_later(ENV["DOC_ID"])
    end

    desc "Harvest all images"
    task harvest_all: :environment do
      query = "*:*"
      index = Geoblacklight::SolrDocument.index
      results = index.send_and_receive(index.blacklight_config.solr_path,
        q: query,
        fl: "*",
        rows: 100_000_000)
      # num_found = results.response[:numFound]
      # doc_counter = 0
      results.docs.each do |document|
        sleep(1)
        begin
          GeoblacklightSidecarImages::StoreImageJob.perform_later(document.id)
        rescue Blacklight::Exceptions::RecordNotFound
          next
        end
      end
    end

    desc "Hash of SolrDocumentSidecar image state counts"
    task harvest_states: :environment do
      states = [
        :initialized,
        :queued,
        :processing,
        :succeeded,
        :failed,
        :placeheld
      ]

      col_state = {}
      states.each do |state|
        sidecars = SolrDocumentSidecar.in_state(state)
        col_state[state] = sidecars.size
      end

      col_state.each do |col, state|
        puts "#{col} - #{state}"
      end
    end

    desc "Re-queues incomplete states for harvesting"
    task harvest_retry: :environment do
      states = [
        :initialized,
        :queued,
        :processing,
        :failed,
        :placeheld
      ]

      states.each do |state|
        sidecars = SolrDocumentSidecar.in_state(state)

        puts "#{state} - #{sidecars.size}"

        sidecars.each do |sc|
          document = Geoblacklight::SolrDocument.find(sc.document_id)
          GeoblacklightSidecarImages::StoreImageJob.perform_later(document.id)
        rescue
          puts "orphaned / #{sc.document_id}"
        end
      end
    end

    desc "Write harvest state report (CSV)"
    task harvest_report: :environment do
      # Create a CSV Dump of Results
      file = "#{Rails.root}/public/#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.sidecar_report.csv"

      sidecars = SolrDocumentSidecar.all

      CSV.open(file, "w") do |writer|
        header = [
          "Sidecar ID",
          "Document ID",
          "Current State",
          "Doc Data Type",
          "Doc Title",
          "Doc Institution",
          "Error",
          "Viewer Protocol",
          "Image URL",
          "GBLSI Thumbnail URL"
        ]

        writer << header

        sidecars.each do |sc|
          # cat = CatalogController.new

          document = Geoblacklight::SolrDocument.find(sc.document_id)
          writer << [
            sc.id,
            sc.document_id,
            sc.image_state.current_state,
            document._source["layer_geom_type_s"],
            document._source["dc_title_s"],
            document._source["dct_provenance_s"],
            sc.image_state.last_transition.metadata["exception"],
            sc.image_state.last_transition.metadata["viewer_protocol"],
            sc.image_state.last_transition.metadata["image_url"],
            sc.image_state.last_transition.metadata["gblsi_thumbnail_uri"]
          ]
        rescue => e
          puts "Exception: #{e.inspect}"
          puts "orphaned / #{sc.document_id}"
          next
        end
      end
    end

    desc "Destroy all harvested images and sidecar AR objects"
    task harvest_purge_all: :environment do
      # Remove all images
      sidecars = SolrDocumentSidecar.all
      sidecars.each do |sc|
        sc.image.purge
      end

      # Delete all Transitions and Sidecars
      SidecarImageTransition.destroy_all
      SolrDocumentSidecar.destroy_all
    end

    desc "Destroy orphaned images and sidecar AR objects"
    # When a SolrDocumentSidecar AR object exists,
    # but it's corresponding SolrDocument is no longer in the Solr index.
    task harvest_purge_orphans: :environment do
      # Remove all images
      sidecars = SolrDocumentSidecar.all
      sidecars.each do |sc|
        Geoblacklight::SolrDocument.find(sc.document_id)
      rescue
        sc.destroy
        puts "orphaned / #{sc.document_id} / destroyed"
      end
    end

    desc "Destroy select sidecar AR objects by CSV file"
    task harvest_destroy_batch: :environment do
      # Expects a CSV file in Rails.root/tmp/destroy_batch.csv
      #
      # From your local machine, copy it up to production server like this:
      # scp destroy_batch.csv swadm@geoprod:/swadm/var/www/geoblacklight/current/tmp/
      CSV.foreach("#{Rails.root}/tmp/destroy_batch.csv", headers: true) do |row|
        sc = SolrDocumentSidecar.find_by(document_id: row[0])
        sc.destroy
        puts "document_id - #{row[0]} - destroyed"
      end
    end

    desc "Inspect failed state objects"
    task harvest_failed_state_inspect: :environment do
      states = [
        :failed
      ]

      states.each do |state|
        SolrDocumentSidecar.in_state(state).each do |sc|
          puts "#{state} - #{sc.document_id} - #{sc.image_state.last_transition.metadata.inspect}"
        end
      end
    end
  end
end
