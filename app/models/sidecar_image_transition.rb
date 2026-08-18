# frozen_string_literal: true

class SidecarImageTransition < GeoblacklightSidecarImages::ApplicationRecord
  self.table_name = "sidecar_image_transitions"

  include Statesman::Adapters::ActiveRecordTransition

  validates :to_state, inclusion: {in: SidecarImageStateMachine.states}

  belongs_to :solr_document_sidecar, inverse_of: :sidecar_image_transitions
end
