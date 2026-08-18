# frozen_string_literal: true

module GeoblacklightSidecarImages
  class Engine < ::Rails::Engine
    isolate_namespace GeoblacklightSidecarImages

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "geoblacklight_sidecar_images.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper GeoblacklightSidecarImages::ApplicationHelper
      end
    end

    config.to_prepare do
      next unless defined?(::SolrDocument)

      unless ::SolrDocument.included_modules.include?(GeoblacklightSidecarImages::SolrDocumentBehavior)
        ::SolrDocument.include GeoblacklightSidecarImages::SolrDocumentBehavior
      end
      unless ::SolrDocument.included_modules.include?(WmsRewriteConcern)
        ::SolrDocument.include WmsRewriteConcern
      end
    end
  end
end
