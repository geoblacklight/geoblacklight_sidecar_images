# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

# require "simplecov"
# SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

# SimpleCov.start "rails" do
# @TODO
# refuse_coverage_drop
# end

require "database_cleaner"
require "capybara/rspec"
require "selenium-webdriver"
require "webdrivers"

require "blacklight"
require "geoblacklight"
require "geoblacklight_sidecar_images"

require "engine_cart"
EngineCart.load_application!

require "rspec/rails"

def json_data(filename)
  file_content = file_fixture("#{filename}.json").read
  JSON.parse(file_content, symbolize_names: true)
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false

  config.before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end

def main_app
  Rails.application.class.routes.url_helpers
end
