module SirTrevorRails::Blocks
  module Textable

    def text?
      text.present?
    end

    def text_align
      send(:'text-align')
    end

    def content_align
      text_align == "left" ? "right" : "left" if text?
    end

    def text
      val = super

      # empty, in sir-trevor speak
      unless val == "<p><br></p>"
        val
      end
    end

  end
end
