# frozen_string_literal: true

##
# Metadata for indexed documents
class SolrDocumentSidecar < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :document, required: true, polymorphic: true
  has_many :sidecar_image_transitions, autosave: false
  has_one_attached :image

  # Roll our own polymorphism because our documents are not AREL-able
  def document
    document_type.new document_type.unique_key => document_id
  end

  def document_type
    (super.constantize if defined?(super)) || default_document_type
  end

  def state_machine
    @state_machine ||= SidecarImageStateMachine.new(
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

  private_class_method :initial_state
end
