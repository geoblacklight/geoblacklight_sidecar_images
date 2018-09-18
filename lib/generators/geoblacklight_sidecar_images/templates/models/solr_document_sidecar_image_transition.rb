class SolrDocumentSidecarImageTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  validates :to_state, inclusion: { in: SolrDocumentSidecarImageStateMachine.states }

  belongs_to :solr_document_sidecar_image, inverse_of: :solr_document_sidecar_image_transitions
end
