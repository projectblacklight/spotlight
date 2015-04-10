module SirTrevorRails
  module Blocks
    ##
    # Carousel with documents and text block
    class SolrDocumentsCarouselBlock < SirTrevorRails::Blocks::SolrDocumentsBlock
      def max_height
        send(:'max-height')
      end

      def interval
        val = send(:'auto-play-images')
        if val == 'true'
          send(:'auto-play-images-interval')
        else
          false
        end
      end
    end
  end
end
