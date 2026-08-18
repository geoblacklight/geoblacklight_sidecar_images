# frozen_string_literal: true

module GeoblacklightSidecarImages
  module SolrDocumentBehavior
    extend ActiveSupport::Concern

    def ogm_thumbnail_url
      GeoblacklightSidecarImages::OgmThumbnail.url_for(self)
    end

    def sidecar
      record = SolrDocumentSidecar.find_or_initialize_by(
        document_id: id,
        document_type: self.class.to_s
      )
      version = _source["_version_"]
      if record.new_record? || record.version != version
        record.version = version
        record.save!
      end
      record
    end
  end
end
