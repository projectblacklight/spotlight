module SirTrevorRails::Blocks
  class ItemTextBlock < SirTrevorRails::Block
    include SolrDocumentBlock

    def doc_id
      send(:'item-id')
    end

    def solr_document
      @solr_document ||= solr_helper.fetch(doc_id).last if doc_id.present?
    end
    
    def text_align
      as_json[:data].find { |k,v| k =~ /text-align/ }.try(:last)
    end
  end
end