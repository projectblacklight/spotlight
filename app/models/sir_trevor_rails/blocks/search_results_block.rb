module SirTrevorRails::Blocks
  class SearchResultsBlock < SirTrevorRails::Block
    def query_params
      if search
        search.query_params
      else
        {}
      end
    end

    def search
      searches.first
    end
    
    def searches
      ids = items.map { |v| v[:id] }
      @searches ||= parent.exhibit.searches.published.where(slug: ids).sort { |a,b| order.index(a.id) <=> order.index(b.id) }
    end

    def searches?
      !searches.empty?
    end

    def items
      item.values.select { |x| x[:display] == "true" }
    end

  end
end