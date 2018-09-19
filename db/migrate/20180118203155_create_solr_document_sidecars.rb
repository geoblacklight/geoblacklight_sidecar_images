class CreateSolrDocumentSidecars < ActiveRecord::Migration[5.2]
  def change
    create_table :solr_document_sidecars do |t|
      t.string "document_id"
      t.string "document_type"
      t.string "image"
      t.index ["document_type", "document_id"], name: "sidecars_solr_document"

      t.timestamps
    end
  end
end
