# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Multi-up browse block
    class BrowseBlock < SirTrevorRails::Block
      include Displayable

      attr_reader :solr_helper

      def with_solr_helper(solr_helper)
        @solr_helper = solr_helper
      end

      def search_options(id)
        (items.detect { |x| x[:id] == id }) || {}
      end

      def searches
        @searches ||= parent.exhibit.searches.published.where(slug: item_ids).sort do |a, b|
          ordered_items.index(a.slug) <=> ordered_items.index(b.slug)
        end
      end

      def searches?
        !searches.empty?
      end

      def display_item_counts?
        send(:'display-item-counts') == 'true'
      end

      def as_json
        result = super

        result[:data][:item] ||= {}

        # TODO: This is a temporary fix that simply removes any item if the search identifier does not exist
        #       We should have a more permanent solution that will allow browse blocks to be updated without erroring
        result[:data][:item].select! { |_, v| parent.exhibit.searches.exists?(v['id']) }

        result[:data][:item].each_value do |v|
          v['thumbnail_image_url'] = parent.exhibit.searches.find(v['id']).thumbnail_image_url
        end

        result
      end
    end
  end
end
