source "https://rubygems.org"

# Declare your gem's dependencies in geoblacklight_sidecar_images.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.

# Please see geoblacklight_sidecar_images.gemspec for dependency information.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

group :development, :test do
end

# To use a debugger
# gem 'byebug', group: [:development, :test]

# BEGIN ENGINE_CART BLOCK
# engine_cart: 1.2.0
# engine_cart stanza: 0.10.0
# the below comes from engine_cart, a gem used to test this Rails engine gem in the context of a Rails app.
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
  gem "geoblacklight", ">= 2.0"
  gem "mini_magick", "~> 4.9.4"
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

if File.exist?("spec/test_app_templates/Gemfile.extra")
  # rubocop:disable Security/Eval
  eval File.read("spec/test_app_templates/Gemfile.extra"), nil, "spec/test_app_templates/Gemfile.extra"
  # rubocop:enable Security/Eval
end
# END ENGINE_CART BLOCK
