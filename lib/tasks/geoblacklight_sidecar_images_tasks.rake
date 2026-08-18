# frozen_string_literal: true

require "csv"
require "fileutils"

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
      conn = Blacklight.default_index.connection
      cursor = "*"
      loop do
        response = conn.get("select", params: {
          q: "*:*",
          fl: "id",
          rows: 500,
          sort: "id asc",
          cursorMark: cursor
        })
        docs = response.dig("response", "docs") || []
        break if docs.empty?

        docs.each do |document|
          GeoblacklightSidecarImages::StoreImageJob.perform_later(document["id"])
        rescue Blacklight::Exceptions::RecordNotFound
          next
        end

        next_cursor = response["nextCursorMark"]
        break if next_cursor.blank? || next_cursor == cursor

        cursor = next_cursor
      end
    end

    desc "Hash of SolrDocumentSidecar image state counts"
    task harvest_states: :environment do
      states = %i[initialized queued processing succeeded failed placeheld]

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
      states = %i[initialized queued processing failed placeheld]

      states.each do |state|
        sidecars = SolrDocumentSidecar.in_state(state)

        puts "#{state} - #{sidecars.size}"

        sidecars.each do |sc|
          document = Geoblacklight::SolrDocument.find(sc.document_id)
          GeoblacklightSidecarImages::StoreImageJob.perform_later(document.id)
        rescue Blacklight::Exceptions::RecordNotFound
          puts "orphaned / #{sc.document_id}"
        end
      end
    end

    desc "Write harvest state report (CSV)"
    task harvest_report: :environment do
      FileUtils.mkdir_p(Rails.root.join("tmp"))
      file = Rails.root.join("tmp", "#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}.sidecar_report.csv")

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
          document = Geoblacklight::SolrDocument.find(sc.document_id)
          writer << [
            sc.id,
            sc.document_id,
            sc.image_state.current_state,
            document._source[GeoblacklightSidecarImages::HarvestTasks.resource_type_field] || document._source["layer_geom_type_s"],
            document._source[GeoblacklightSidecarImages::HarvestTasks.title_field],
            document._source[GeoblacklightSidecarImages::HarvestTasks.provider_field],
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

      puts "Wrote #{file}"
    end

    desc "Destroy all harvested images and sidecar AR objects (CONFIRM=1 required)"
    task harvest_purge_all: :environment do
      GeoblacklightSidecarImages::HarvestTasks.require_confirmation!

      sidecars = SolrDocumentSidecar.all
      sidecars.each do |sc|
        sc.image.purge if sc.image.attached?
      end

      SidecarImageTransition.destroy_all
      SolrDocumentSidecar.destroy_all
    end

    desc "Destroy orphaned images and sidecar AR objects (CONFIRM=1 required)"
    task harvest_purge_orphans: :environment do
      GeoblacklightSidecarImages::HarvestTasks.require_confirmation!

      sidecars = SolrDocumentSidecar.all
      sidecars.each do |sc|
        Geoblacklight::SolrDocument.find(sc.document_id)
      rescue Blacklight::Exceptions::RecordNotFound
        sc.destroy
        puts "orphaned / #{sc.document_id} / destroyed"
      end
    end

    desc "Destroy select sidecar AR objects by CSV file (CONFIRM=1 required)"
    task harvest_destroy_batch: :environment do
      GeoblacklightSidecarImages::HarvestTasks.require_confirmation!

      CSV.foreach("#{Rails.root}/tmp/destroy_batch.csv", headers: true) do |row|
        sc = SolrDocumentSidecar.find_by(document_id: row[0])
        if sc
          sc.destroy
          puts "document_id - #{row[0]} - destroyed"
        else
          puts "document_id - #{row[0]} - not found"
        end
      end
    end

    desc "Inspect failed state objects"
    task harvest_failed_state_inspect: :environment do
      SolrDocumentSidecar.in_state(:failed).each do |sc|
        puts "failed - #{sc.document_id} - #{sc.image_state.last_transition.metadata.inspect}"
      end
    end
  end
end

module GeoblacklightSidecarImages
  module HarvestTasks
    module_function

    def require_confirmation!
      return if ENV["CONFIRM"] == "1"

      abort "Refusing to run a destructive harvest task without CONFIRM=1"
    end

    def title_field
      Settings.FIELDS.TITLE || "dct_title_s"
    end

    def provider_field
      Settings.FIELDS.PROVIDER || "schema_provider_s"
    end

    def resource_type_field
      Settings.FIELDS.RESOURCE_TYPE || "gbl_resourceType_sm"
    end
  end
end
