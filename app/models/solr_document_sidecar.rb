# frozen_string_literal: true

##
# ActiveRecord sidecar for a Solr document, with an attached thumbnail image.
class SolrDocumentSidecar < GeoblacklightSidecarImages::ApplicationRecord
  self.table_name = "solr_document_sidecars"

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: SidecarImageTransition,
    initial_state: :initialized
  ]

  belongs_to :document, optional: false, polymorphic: true
  has_many :sidecar_image_transitions, autosave: false, dependent: :destroy
  has_one_attached :image

  # SolrDocument is not an ActiveRecord model. Reconstruct from the stored id.
  def document
    document_type.new document_type.unique_key => document_id
  end

  def document_type
    (super.constantize if defined?(super)) || default_document_type
  end

  def image_state
    @image_state ||= SidecarImageStateMachine.new(
      self,
      transition_class: SidecarImageTransition
    )
  end

  def self.transition_class
    SidecarImageTransition
  end

  def self.initial_state
    :initialized
  end

  def image_url
    return unless image.attached?

    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end

  def reimage!
    image.purge if image.attached?
    GeoblacklightSidecarImages::StoreImageJob.perform_later(document.id)
  end

  private_class_method :initial_state
end
