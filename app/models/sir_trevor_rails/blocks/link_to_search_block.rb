# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Embed search results (from a browse category) into the page
    class LinkToSearchBlock < BrowseBlock
      include Displayable

      def searches
        @searches ||= parent.exhibit.searches.where(slug: item_ids).sort do |a, b|
          ordered_items.index(a.slug) <=> ordered_items.index(b.slug)
        end
      end
    end
  end
end
