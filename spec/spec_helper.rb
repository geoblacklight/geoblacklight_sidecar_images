# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "simplecov"
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

SimpleCov.start "rails" do
  # @TODO
  # refuse_coverage_drop
end

require "database_cleaner"
require "engine_cart"
EngineCart.load_application!

require "rspec/rails"
require "capybara/rspec"
require "selenium-webdriver"
require "webdrivers"

def json_data(filename)
  file_content = file_fixture("#{filename}.json").read
  JSON.parse(file_content, symbolize_names: true)
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
