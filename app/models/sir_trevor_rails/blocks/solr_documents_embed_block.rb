# frozen_string_literal: true

module SirTrevorRails
  module Blocks
    ##
    # Embed documents (using a special blacklight view configuration) and text block
    class SolrDocumentsEmbedBlock < SirTrevorRails::Blocks::SolrDocumentsBlock
      def self.supports_alt_text?
        false
      end
    end
  end
end
