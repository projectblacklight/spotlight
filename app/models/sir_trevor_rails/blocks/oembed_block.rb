# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # OEmbed consumer with text
    class OembedBlock < SirTrevorRails::Block
      include Textable
    end
  end
end
