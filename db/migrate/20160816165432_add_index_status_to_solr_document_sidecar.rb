class AddIndexStatusToSolrDocumentSidecar < ActiveRecord::Migration[4.2]
  def change
    add_column :spotlight_solr_document_sidecars, :index_status, :binary
  end
end
