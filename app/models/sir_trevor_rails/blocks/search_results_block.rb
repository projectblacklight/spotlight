module SirTrevorRails
  module Blocks
    ##
    # Embed search results (from a browse category) into the page
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
        @searches ||= parent.exhibit.searches.published.where(slug: item_ids).sort { |a, b| order.index(a.id) <=> order.index(b.id) }
      end

      def item_ids
        items.map { |v| v[:id] }
      end

      def searches?
        !searches.empty?
      end

      def items
        item.values.select { |x| x[:display] == 'true' }
      end
    end
  end
end
