module SirTrevorRails
  module Blocks
    ##
    # Multi-up browse block
    class BrowseBlock < SirTrevorRails::Block
      attr_reader :solr_helper

      def with_solr_helper(solr_helper)
        @solr_helper = solr_helper
      end

      def search_options(id)
        (items.detect { |x| x[:id] == id }) || {}
      end

      def searches
        @searches ||= parent.exhibit.searches.published.where(slug: item_ids).sort do |a, b|
          order.index(a.slug) <=> order.index(b.slug)
        end
      end

      def searches?
        !searches.empty?
      end

      def item_ids
        items.map { |v| v[:id] }
      end

      def items
        item_values.select { |x| x[:display] == 'true' }
      end

      def order
        items.sort_by { |x| x[:weight] }.map { |x| x[:id] }
      end

      def display_item_counts?
        send(:'display-item-counts') == 'true'
      end

      private

      def item_values
        item.try(:values) || []
      end
    end
  end
end
