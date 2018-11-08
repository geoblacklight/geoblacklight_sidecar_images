class SidecarImageTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  validates :to_state, inclusion: { in: SidecarImageStateMachine.states }

  belongs_to :solr_document_sidecar, inverse_of: :sidecar_image_transitions
end
