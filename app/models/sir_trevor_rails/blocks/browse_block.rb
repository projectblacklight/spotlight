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

        result[:data][:item].each do |_k, v|
          v['thumbnail_image_url'] = parent.exhibit.searches.find(v['id']).thumbnail_image_url
        end

        result
      end
    end
  end
end
