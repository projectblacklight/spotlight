module SirTrevorRails
  module Blocks
    ##
    # Multi-up featured page block
    class FeaturedPagesBlock < SirTrevorRails::Block
      def page_options(id)
        (items.detect { |x| x[:id] == id }) || {}
      end

      def pages
        @pages ||= parent.exhibit.pages.published.where(slug: item_ids).sort { |a, b| order.index(a.id) <=> order.index(b.id) }
      end

      def pages?
        !pages.empty?
      end

      def item_ids
        items.map { |v| v[:id] }
      end

      def items
        item.values.select { |x| x[:display] == 'true' }
      end

      def order
        items.sort_by { |x| x[:weight] }.map { |x| x[:id] }
      end
    end
  end
end
