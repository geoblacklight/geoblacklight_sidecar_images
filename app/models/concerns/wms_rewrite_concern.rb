# frozen_string_literal: true

module WmsRewriteConcern
  extend ActiveSupport::Concern

  def viewer_endpoint
    if local_restricted? && geoserver_proxy_configured?
      super.gsub(Settings.INSTITUTION_GEOSERVER_URL, Settings.PROXY_GEOSERVER_URL)
    else
      super
    end
  end

  def local_restricted?
    local? && restricted?
  end

  def local?
    name = Settings.INSTITUTION_LOCAL_NAME.to_s
    return false if name.blank?

    fetch(Settings.FIELDS.PROVIDER, "").casecmp(name).zero?
  end

  private

  def geoserver_proxy_configured?
    Settings.INSTITUTION_GEOSERVER_URL.to_s.present? &&
      Settings.PROXY_GEOSERVER_URL.to_s.present?
  end
end
