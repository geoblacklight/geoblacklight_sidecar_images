# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.internal_test_app/"
end

ENV["RAILS_ENV"] ||= "test"

require "logger"
require "webmock/rspec"

require "capybara/rspec"
require "selenium-webdriver"

require "rails/all"
require "blacklight"
blacklight_root = Gem.loaded_specs.fetch("blacklight").full_gem_path

begin
  require File.join(blacklight_root, "app/controllers/concerns/blacklight/search_fields")
  require File.join(blacklight_root, "app/controllers/concerns/blacklight/controller")
rescue LoadError
  # Blacklight 8+ autoloads these
end

require "geoblacklight"
require "geoblacklight_sidecar_images"

require "engine_cart"
EngineCart.load_application!

require "rspec/rails"

WebMock.disable_net_connect!(allow_localhost: true)

GEM_SPEC_ROOT = File.expand_path(__dir__)

def json_data(filename)
  file_content = File.read(File.join(GEM_SPEC_ROOT, "fixtures", "files", "#{filename}.json"))
  JSON.parse(file_content, symbolize_names: true)
end

RSpec.configure do |config|
  if config.respond_to?(:fixture_paths=)
    config.fixture_paths = [Rails.root.join("spec/fixtures")]
  end

  config.use_transactional_fixtures = true

  config.before do
    ActiveJob::Base.queue_adapter = :test
  end
end

def main_app
  Rails.application.class.routes.url_helpers
end
