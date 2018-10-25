namespace :gblsci do
  namespace :sample_data do
    desc 'Ingests a directory of geoblacklight.json files'
    task :ingest, [:directory] => :environment do |_t, args|
      args.with_defaults(directory: 'data')
      Dir.glob(File.join(args[:directory], '**', '*.json')).each do |fn|
        puts "Ingesting #{fn}"
        begin
          Blacklight.default_index.connection.add(JSON.parse(File.read(fn)))
        rescue => e
          puts "Failed to ingest #{fn}: #{e.inspect}"
        end
      end
      puts 'Committing changes to Solr'
      Blacklight.default_index.connection.commit
    end
  end

  namespace :images do
    desc 'Pre-cache specific image'
    task :precache_id, [:doc_id] => [:environment] do |_t, args|
      query = "dc_identifier_s:#{args[:doc_id]}"
      #query = "dc_identifier_s:bdcbcd3e-f6db-4ee4-b7b7-d75fe35f1d92"
      index = Geoblacklight::SolrDocument.index
      results = index.send_and_receive(index.blacklight_config.solr_path,
                                       q: query,
                                       fl: "*",
                                       rows: 100_000_000)
      num_found = results.response[:numFound]
      doc_counter = 0
      results.docs.each do |document|
        begin
          StoreImageJob.perform_later(document.id)
        rescue Blacklight::Exceptions::RecordNotFound
          next
        end
      end
    end

    desc 'Pre-cache all images'
    task :precache_all, [:override_existing] => [:environment] do |_t, args|
      begin
        query = '*:*'
        index = Geoblacklight::SolrDocument.index
        results = index.send_and_receive(index.blacklight_config.solr_path,
                                         q: query,
                                         fl: "*",
                                         rows: 100_000_000)
        num_found = results.response[:numFound]
        doc_counter = 0
        results.docs.each do |document|
          sleep(1)
          begin
            StoreImageJob.perform_later(document.id)
          rescue Blacklight::Exceptions::RecordNotFound
            next
          end
        end
      end
    end
  end

  namespace :sidecars do
    desc 'Hash of SolrDocumentSidecar state counts'
    task sidecar_states: :environment do
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

      col_state.each do |col,state|
        puts "#{col} - #{state}"
      end
    end

    desc 'Queue incomplete states for reprocessing'
    task queue_incomplete_states: :environment do
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
          cat = CatalogController.new
          begin
            resp, doc = cat.fetch(sc.document_id)
            StoreImageJob.perform_later(doc.id)
          rescue
            puts "orphaned / #{sc.document_id}"
          end
        end
      end
    end

    desc 'Failed State - Inspect metadata'
    task failed_state_inspect: :environment do
      states = [
        :failed
      ]

      states.each do |state|
        sidecars = SolrDocumentSidecar.in_state(state).each do |sc|
          puts "#{state} - #{sc.document_id} - #{sc.state_machine.last_transition.metadata.inspect}"
        end
      end
    end
  end
end
