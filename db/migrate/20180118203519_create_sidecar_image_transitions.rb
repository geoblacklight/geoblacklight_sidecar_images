# frozen_string_literal: true

class CreateSidecarImageTransitions < ActiveRecord::Migration[7.2]
  def change
    create_table :sidecar_image_transitions do |t|
      t.string :to_state, null: false
      t.text :metadata
      t.integer :sort_key, null: false
      t.bigint :solr_document_sidecar_id, null: false
      t.boolean :most_recent

      t.timestamps null: false
    end

    add_foreign_key :sidecar_image_transitions, :solr_document_sidecars

    add_index(:sidecar_image_transitions,
      [:solr_document_sidecar_id, :sort_key],
      unique: true,
      name: "index_sidecar_image_transitions_parent_sort")
    add_index(:sidecar_image_transitions,
      [:solr_document_sidecar_id, :most_recent],
      unique: true,
      name: "index_sidecar_image_transitions_parent_most_recent")
  end
end
