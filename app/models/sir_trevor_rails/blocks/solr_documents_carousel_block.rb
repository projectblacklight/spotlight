# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Carousel with documents and text block
    class SolrDocumentsCarouselBlock < SirTrevorRails::Blocks::SolrDocumentsBlock
      def max_height
        send(:'max-height')
      end

      def autoplay?
        send(:'auto-play-images') == 'true'
      end

      def interval
        if autoplay?
          send(:'auto-play-images-interval')
        else
          false
        end
      end
    end
  end
end
