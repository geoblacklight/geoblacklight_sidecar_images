begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'solr_wrapper'
require 'engine_cart/rake_task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'geoblacklight_sidecar_images/version'

EngineCart.fingerprint_proc = EngineCart.rails_fingerprint_proc

task ci: ['engine_cart:generate'] do
  ENV['environment'] = 'test'

  SolrWrapper.wrap(port: '8983') do |solr|
    solr.with_collection(name: 'blacklight-core', dir: File.join(__dir__, 'solr_conf', 'conf')) do
      # Rake::Task['spotlight:fixtures'].invoke

      # run the tests
      Rake::Task['spec'].invoke
    end
  end
end

task default: %i[rubocop ci]
