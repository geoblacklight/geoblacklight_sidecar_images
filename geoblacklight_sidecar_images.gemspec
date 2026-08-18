$LOAD_PATH.push File.expand_path("../lib", __FILE__)

require "geoblacklight_sidecar_images/version"

Gem::Specification.new do |s|
  s.name = "geoblacklight_sidecar_images"
  s.version = GeoblacklightSidecarImages::VERSION
  s.authors = ["Eric Larson", "Eliot Jordan"]
  s.email = ["ewlarson@gmail.com"]
  s.homepage = "https://github.com/geoblacklight/geoblacklight_sidecar_images"
  s.summary = "Store local copies of remote imagery in GeoBlacklight"
  s.license = "Apache 2.0"
  s.required_ruby_version = ">= 3.3"

  s.files = `git ls-files -z`.split(%(\x0))
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "csv"
  s.add_dependency "faraday", ">= 2.0"
  s.add_dependency "faraday-follow_redirects"
  s.add_dependency "geoblacklight", ">= 4.0", "< 7"
  s.add_dependency "image_processing", "~> 1.6"
  s.add_dependency "marcel", ">= 1.0"
  s.add_dependency "rails", ">= 7.2", "< 9"
  s.add_dependency "statesman", ">= 3.4"

  s.add_development_dependency "capybara"
  s.add_development_dependency "engine_cart", "~> 2.0"
  s.add_development_dependency "rspec-rails", ">= 6.0"
  s.add_development_dependency "selenium-webdriver"
  s.add_development_dependency "simplecov", "~> 0.22"
  s.add_development_dependency "solr_wrapper", "~> 4.0"
  s.add_development_dependency "standard", "~> 1.0"
  s.add_development_dependency "webmock", "~> 3.14"
end
