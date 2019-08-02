# frozen_string_literal: true

##
# Metadata for indexed documents
class SolrDocumentSidecar < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :document, optional: false, polymorphic: true
  has_many :sidecar_image_transitions, autosave: false
  has_one_attached :image

  # If the sidecar solr document is updated, re-fetch thumbnail image
  after_update :reimage, if: :saved_change_to_version?

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

  def self.image_url
    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end

  private_class_method :initial_state

  private

  def reimage
    image.purge if image.attached?
    GeoblacklightSidecarImages::StoreImageJob.perform_later(document.id)
  end
end
