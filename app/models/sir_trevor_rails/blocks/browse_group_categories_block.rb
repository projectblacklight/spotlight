# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Browese Group Categories
    class BrowseGroupCategoriesBlock < SirTrevorRails::Block
      include Displayable

      def display_item_counts?
        send(:'display-item-counts') == 'true'
      end

      def groups
        @groups ||= parent.exhibit.groups.published.where(slug: item_ids).sort do |a, b|
          ordered_items.index(a.slug) <=> ordered_items.index(b.slug)
        end
      end

      def groups?
        !groups.empty?
      end
    end
  end
end
