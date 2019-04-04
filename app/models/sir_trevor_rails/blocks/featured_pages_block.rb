# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Multi-up featured page block
    class FeaturedPagesBlock < SirTrevorRails::Block
      include Displayable

      def page_options(id)
        (items.detect { |x| x[:id] == id }) || {}
      end

      def pages
        @pages ||= parent.exhibit.pages.published.where(slug: item_ids).sort do |a, b|
          ordered_items.index(a.slug) <=> ordered_items.index(b.slug)
        end
      end

      def pages?
        !pages.empty?
      end

      def as_json
        result = super

        result[:data][:item] ||= {}

        result[:data][:item].each_value do |v|
          v['thumbnail_image_url'] = parent.exhibit.pages.find(v['id']).thumbnail_image_url
        end

        result
      end
    end
  end
end
