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
        @pages ||= parent.exhibit.pages.for_default_locale.published.where(slug: item_ids).sort do |a, b|
          ordered_items.index(a.slug) <=> ordered_items.index(b.slug)
        end
      end

      def pages?
        !pages.empty?
      end

      # rubocop:disable Metrics/MethodLength
      def as_json(*)
        result = super
        result[:data][:item] ||= {}

        result[:data][:item].transform_values! do |v|
          begin
            v['thumbnail_image_url'] = parent.exhibit.pages.for_default_locale.find(v['id']).thumbnail_image_url
          rescue ActiveRecord::RecordNotFound
            v = nil
          end
          v
        end

        result[:data][:item].compact!
        result
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
