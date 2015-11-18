module SirTrevorRails
  module Blocks
    ###
    # Uploaded images with text
    ###
    class UploadedItemsBlock < SirTrevorRails::Block
      include Textable

      def files
        (item || {}).map { |_, file| file }.select { |file| file[:display].to_s == 'true' }
      end
    end
  end
end
