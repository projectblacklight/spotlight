# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Embed search results (from a browse category) into the page
    class SearchResultsBlock < SirTrevorRails::Block
      include Displayable

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
        @searches ||= parent.exhibit.searches.published.where(slug: item_ids).sort { |a, b| ordered_items.index(a.id) <=> ordered_items.index(b.id) }
      end

      def searches?
        !searches.empty?
      end
    end
  end
end
