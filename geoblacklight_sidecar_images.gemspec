$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'geoblacklight_sidecar_images/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'geoblacklight_sidecar_images'
  s.version     = GeoblacklightSidecarImages::VERSION
  s.authors     = ['Eric Larson', 'Eliot Jordan']
  s.email       = ['ewlarson@umn.edu']
  s.homepage    = 'https://github.com/geoblacklight/geoblacklight_sidecar_images'
  s.summary     = 'Store local copies of remote imagery in GeoBlacklight'
  s.license     = 'Apache 2.0'

  s.files         = `git ls-files -z`.split(%Q{\x0})
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'geoblacklight', '~> 3.0'
  s.add_dependency 'mini_magick', '~> 4.9.4'
  s.add_dependency 'image_processing', '~> 1.6'
  s.add_dependency 'statesman', '~> 3.4'
  s.add_dependency 'mimemagic', '~> 0.3'
  s.add_dependency 'rails', '>= 5.2', '< 6'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'webdrivers'
  s.add_development_dependency 'database_cleaner', '~> 1.3'
  s.add_development_dependency 'engine_cart', '~> 2.2'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 0.60.0'
  s.add_development_dependency 'rubocop-rspec', '~> 1.30.0'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'solr_wrapper', '~> 2.2'
  s.add_development_dependency 'sprockets', '< 4'
end
