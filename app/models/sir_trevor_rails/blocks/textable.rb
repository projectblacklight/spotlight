module SirTrevorRails
  module Blocks
    ##
    # Mixin for blocks that display text
    module Textable
      def text?
        text.present?
      end

      def text_align
        send(:'text-align')
      end

      def content_align
        text_align == 'left' ? 'right' : 'left' if text?
      end

      def text
        val = super

        # empty, in sir-trevor speak
        val unless val == '<p><br></p>'
      end
    end
  end
end
