module Spotlight::Resources
  class IiifItem < Spotlight::Resource

    def compound_id
      "#{exhibit.id}-#{id}"
    end

    def add_document_id(solr_hash)
      solr_hash[exhibit.blacklight_config.document_model.unique_key.to_sym] = compound_id
    end

    def to_solr
      solr_hash=super

      add_document_id solr_hash
      solr_hash.merge(data)
      
      solr_hash
   end

  end
end
