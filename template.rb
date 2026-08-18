# frozen_string_literal: true

# $ rails new app-name -m https://raw.githubusercontent.com/geoblacklight/geoblacklight_sidecar_images/develop/template.rb

gem "blacklight"
gem "geoblacklight", ">= 5.0"
gem "statesman", ">= 3.4"
gem "geoblacklight_sidecar_images", ">= 2.0"

run "bundle install"

generate "blacklight:install", "--devise", "--skip-solr"
generate "geoblacklight:install", "--force"
generate "geoblacklight_sidecar_images:install", "--force"

rake "db:migrate"
