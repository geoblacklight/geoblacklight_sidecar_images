class SolrDocumentSidecarImage < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries

  has_many :solr_document_sidecar_image_transitions, autosave: false

  def state_machine
    @state_machine ||= SolrDocumentSidecarImageStateMachine.new(
      self,
      transition_class: SolrDocumentSidecarImageTransition
    )
  end

  def self.transition_class
    SolrDocumentSidecarImageTransition
  end

  def self.initial_state
    :initialized
  end

  private_class_method :initial_state
end
