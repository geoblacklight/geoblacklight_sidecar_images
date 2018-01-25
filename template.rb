# $ rails _5.1.4_ new app-name -m https://raw.githubusercontent.com/ewlarson/geoblacklight_sidecar_images/master/template.rb

gem 'blacklight', '>= 6.3'
gem 'geoblacklight', '>= 1.4'
gem 'geoblacklight_sidecar_images', github: 'ewlarson/geoblacklight_sidecar_images', branch: 'master'

run 'bundle install'

generate 'blacklight:install', '--devise'
generate 'geoblacklight:install', '-f'
generate 'geoblacklight_sidecar_images:install', '-f'

rake 'db:migrate'
