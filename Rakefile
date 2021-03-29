# frozen_string_literal: true

require 'rails'
begin
  require 'bundler/setup'
  require 'bundler/gem_tasks'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require 'solr_wrapper'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

require 'solr_wrapper/rake_task'
require 'engine_cart/rake_task'
require 'geoblacklight_sidecar_images/version'

task ci: ['engine_cart:generate'] do
  ENV['environment'] = 'test'
  SolrWrapper.wrap do |solr|
    solr.with_collection(name: 'blacklight-core', dir: File.join(__dir__, 'solr', 'conf')) do
      # run the tests
      Rake::Task['spec'].invoke
    end
  end
end

task default: %i[rubocop ci]
