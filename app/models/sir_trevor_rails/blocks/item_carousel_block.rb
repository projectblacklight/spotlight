module SirTrevorRails::Blocks
  class ItemCarouselBlock < SirTrevorRails::Block
    include SolrDocumentBlock

    def max_height
      as_json[:data].find { |k,v| k =~ /max-height/ }.try(:last)
    end
  end
end