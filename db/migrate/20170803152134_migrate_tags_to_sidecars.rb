class MigrateTagsToSidecars < ActiveRecord::Migration[5.0]
  def up
    Spotlight::SolrDocumentSidecar.reset_column_information
    ActsAsTaggableOn::Tagging.reset_column_information

    ActsAsTaggableOn::Tagging.where(taggable_type: 'SolrDocument', tagger_type: 'Spotlight::Exhibit').find_each do |e|
      sidecar = Spotlight::SolrDocumentSidecar.find_or_create_by(document_id: e.taggable_id, document_type: 'SolrDocument', exhibit_id: e.tagger_id)
      e.update(taggable: sidecar)
    end
  end
  
  def down
    ActsAsTaggableOn::Tagging.where(taggable_type: 'Spotlight::SolrDocumentSidecar').find_each do |e|
      e.update(taggable: e.taggable.document)
    end
  end
end
