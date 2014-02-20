class CreateSpotlightSolrDocumentSidecars < ActiveRecord::Migration
  def change
    create_table :spotlight_solr_document_sidecars do |t|
      t.references :exhibit, index: true
      t.string :solr_document_id, index: true
      t.boolean :public, default: true
      t.text :data

      t.timestamps
    end
  end
end
