# frozen_string_literal: true

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require 'solr_wrapper'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'engine_cart/rake_task'
require 'geoblacklight_sidecar_images/version'

task ci: ['engine_cart:generate'] do
  ENV['environment'] = 'test'

  SolrWrapper.wrap(port: '8983') do |solr|
    solr.with_collection(name: 'blacklight-core', dir: File.join(__dir__, 'solr', 'conf')) do
      # Fixtures here
      # Rake::Task['spotlight:fixtures'].invoke

      # run the tests
      Rake::Task['spec'].invoke
    end
  end
end

task default: %i[rubocop ci]
