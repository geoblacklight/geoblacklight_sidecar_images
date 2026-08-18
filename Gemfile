source "https://rubygems.org"

gemspec

# Ruby 4 removed cgi from default gems
gem "cgi" if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("4.0.0")

# BEGIN ENGINE_CART BLOCK
# engine_cart: 1.2.0
# engine_cart stanza: 0.10.0
file = File.expand_path("Gemfile", ENV["ENGINE_CART_DESTINATION"] || ENV["RAILS_ROOT"] || File.expand_path(".internal_test_app", File.dirname(__FILE__)))

if File.exist?(file)
  begin
    eval_gemfile file
  rescue Bundler::GemfileError => e
    Bundler.ui.warn "[EngineCart] Skipping Rails application dependencies:"
    Bundler.ui.warn e.message
  end
else
  Bundler.ui.warn "[EngineCart] Unable to find test application dependencies in #{file}, using placeholder dependencies"
  gem "geoblacklight", ENV["GEOBLACKLIGHT_VERSION"] || ">= 4.0"
  gem "image_processing", "~> 1.6"
  gem "statesman", ">= 3.4"
  gem "marcel", ">= 1.0"
  if ENV["RAILS_VERSION"]
    if ENV["RAILS_VERSION"] == "edge"
      gem "rails", github: "rails/rails"
      ENV["ENGINE_CART_RAILS_OPTIONS"] = "--edge --skip-turbolinks"
    else
      gem "rails", ENV["RAILS_VERSION"]
    end
  end
end

extra = File.expand_path("spec/test_app_templates/Gemfile.extra", File.dirname(__FILE__))
eval_gemfile extra if File.exist?(extra)
# END ENGINE_CART BLOCK
