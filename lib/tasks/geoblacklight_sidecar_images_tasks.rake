namespace :geoblacklight_sidecar_images do
  namespace :sample_data do
    desc "Ingests a directory of geoblacklight.json files"
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
      puts "Committing changes to Solr"
      Blacklight.default_index.connection.commit
    end
  end

  namespace :images do
    desc 'Pre-cache all images'
    task :precache_all, [:override_existing] => [:environment] do |_t, args|
      begin
        query = "layer_slug_s:*"
        layers = 'layer_slug_s, layer_id_s, dc_rights_s, dct_provenance_s, layer_geom_type_s, dct_references_s'
        index = Geoblacklight::SolrDocument.index
        results = index.send_and_receive(index.blacklight_config.solr_path,
                                         q: query,
                                         fl: layers,
                                         rows: 100_000_000)
        num_found = results.response[:numFound]
        doc_counter = 0
        results.docs.each do |document|
          doc_counter += 1
          puts "#{document[:layer_slug_s]} (#{doc_counter}/#{num_found})"
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
