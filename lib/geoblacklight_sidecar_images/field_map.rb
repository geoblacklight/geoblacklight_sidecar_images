# frozen_string_literal: true

module GeoblacklightSidecarImages
  # Resolves Aardvark Solr field names across GBL 4/5 (`Settings.FIELDS.TITLE`)
  # and GBL 6 (`GeoBlacklight.configuration.fields.title`). GBL 6 no longer
  # ships a `FIELDS` block in settings.yml, so callers must not assume it exists.
  module FieldMap
    DEFAULTS = {
      provider: "schema_provider_s",
      resource_class: "gbl_resourceClass_sm",
      resource_type: "gbl_resourceType_sm",
      title: "dct_title_s",
      wxs_identifier: "gbl_wxsIdentifier_s"
    }.freeze

    module_function

    def [](name)
      key = name.to_s.downcase.to_sym
      from_gbl_configuration(key) || from_settings(key) || DEFAULTS.fetch(key)
    end

    def from_gbl_configuration(key)
      return unless defined?(Geoblacklight) && Geoblacklight.respond_to?(:configuration)

      fields = Geoblacklight.configuration.fields
      return unless fields.respond_to?(key)

      fields.public_send(key).presence
    rescue NoMethodError
      nil
    end

    def from_settings(key)
      return unless defined?(Settings)

      fields = Settings.try(:FIELDS)
      return unless fields

      upcase = key.to_s.upcase
      read_key(fields, upcase) || read_key(fields, upcase.to_sym)
    end

    def read_key(fields, candidate)
      value = fields[candidate] if fields.respond_to?(:[])
      value = fields.try(candidate) if value.blank?
      value.presence
    end
  end
end
