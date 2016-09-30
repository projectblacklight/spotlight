class AddDocumentIndexToSolrDocumentSidecar < ActiveRecord::Migration
  def change
    add_index :spotlight_solr_document_sidecars, [:exhibit_id, :document_type, :document_id], name: 'spotlight_solr_document_sidecars_exhibit_document'
    add_index :spotlight_solr_document_sidecars, [:document_type, :document_id], name: 'spotlight_solr_document_sidecars_solr_document'
  end
end
