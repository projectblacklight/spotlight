class AddUniqueIndexToSidecars < ActiveRecord::Migration[5.0]
  def up
    add_index(:spotlight_solr_document_sidecars, [:exhibit_id, :document_type, :document_id], unique: true, name: :by_exhibit_and_doc)
  end

  def down
    remove_index(:spotlight_solr_document_sidecars, name: :by_exhibit_and_doc)
  end
end
