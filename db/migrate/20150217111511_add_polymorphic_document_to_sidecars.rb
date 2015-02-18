class AddPolymorphicDocumentToSidecars < ActiveRecord::Migration
  def change
    add_column :spotlight_solr_document_sidecars, :document_id, :string
    add_column :spotlight_solr_document_sidecars, :document_type, :string
    
    remove_column :spotlight_solr_document_sidecars, :solr_document_id
    
    reversible do |dir|
      dir.up do
        Spotlight::SolrDocumentSidecar.find_each do |e|
          e.document = SolrDocument.new(id: e.solr_document_id)
          e.save!
        end
      end

      dir.down do
        Spotlight::SolrDocumentSidecar.find_each do |e|
          e.solr_document_id = e.document_id
          e.save!
        end
      end
    end

    add_index :bookmarks, [:document_type, :document_id]
  end
end
