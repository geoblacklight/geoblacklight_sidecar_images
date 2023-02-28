# $ rails _5.2.2_ new app-name -m https://raw.githubusercontent.com/geoblacklight/geoblacklight_sidecar_images/master/template.rb

gem "blacklight", ">= 7.0"
gem "geoblacklight", ">= 2.0"
gem "statesman", ">= 3.4"
gem "geoblacklight_sidecar_images", git: "git://github.com/ewlarson/geoblacklight_sidecar_images.git", branch: "master"

run "bundle install"

generate "blacklight:install", "--devise"
generate "geoblacklight:install", "--force"
generate "geoblacklight_sidecar_images:install", "--force"

rake "db:migrate"
