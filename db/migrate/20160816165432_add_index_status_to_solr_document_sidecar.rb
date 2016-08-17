class AddIndexStatusToSolrDocumentSidecar < ActiveRecord::Migration
  def change
    add_column :spotlight_solr_document_sidecars, :index_status, :binary
  end
end
