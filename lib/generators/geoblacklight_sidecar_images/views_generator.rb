# frozen_string_literal: true

require 'rails/generators'

module GeoblacklightSidecarImages
  class ViewsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Creates an app/views/catalog directory
    DESCRIPTION

    def create_views
      copy_file(
        'views/catalog/_index_split_default.html.erb',
        'app/views/catalog/_index_split_default.html.erb'
      )
    end
  end
end
