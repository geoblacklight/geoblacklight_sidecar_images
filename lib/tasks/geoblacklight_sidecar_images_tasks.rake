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
          StoreImageJob.perform_later(document.to_h)
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
            StoreImageJob.perform_later(document.to_h)
          rescue Blacklight::Exceptions::RecordNotFound
            next
          end
        end
      end
    end
  end
end
