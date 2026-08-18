# frozen_string_literal: true

class CreateSolrDocumentSidecars < ActiveRecord::Migration[7.2]
  def change
    create_table :solr_document_sidecars do |t|
      t.string "document_id"
      t.string "document_type"
      t.string "image"
      t.integer "version", limit: 8

      t.index ["document_type", "document_id"], name: "sidecars_solr_document"

      t.timestamps
    end
  end
end
