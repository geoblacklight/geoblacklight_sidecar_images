# $ rails _5.2.1_ new app-name -m https://raw.githubusercontent.com/ewlarson/geoblacklight_sidecar_images/master/template.rb

gem 'blacklight', '>= 6.3'
gem 'geoblacklight', '>= 1.4'
gem 'geoblacklight_sidecar_images', :git => "git://git@github.com:ewlarson/geoblacklight_sidecar_images.git", :branch => "feature/rails-5.2"

run 'bundle install'

generate 'blacklight:install', '--devise'
generate 'geoblacklight:install', '--force'
generate 'geoblacklight_sidecar_images:install', '--force'

rake 'db:migrate'
