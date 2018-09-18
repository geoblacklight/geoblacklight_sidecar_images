# frozen_string_literal: true

##
# Metadata for indexed documents
class SolrDocumentSidecar < ApplicationRecord
  belongs_to :document, required: true, polymorphic: true

  has_one_attached :image

  # Roll our own polymorphism because our documents are not AREL-able
  def document
    document_type.new document_type.unique_key => document_id
  end

  def document_type
    (super.constantize if defined?(super)) || default_document_type
  end
end
