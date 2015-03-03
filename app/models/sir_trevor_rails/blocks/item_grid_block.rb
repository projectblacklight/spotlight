module SirTrevorRails::Blocks
  class ItemGridBlock < SirTrevorRails::Block
    include SolrDocumentBlock
    
    def text_align
      as_json[:data].find { |k,v| k =~ /text-align/ }.try(:last)
    end
  end
end