# frozen_string_literal: true

# Required for 0.6 and up:
module SirTrevorRails
  # https://github.com/madebymany/sir-trevor-rails#upgrade-guide-to-v060
  class Block
    def self.custom_block_types
      %w[
        Browse
        FeaturedPages
        Iframe
        LinkToSearch
        Oembed
        Rule
        SearchResults
        SolrDocuments
        SolrDocumentsCarousel
        SolrDocumentsEmbed
        SolrDocumentsFeatures
        SolrDocumentsGrid
        UploadedItems
      ]
    end
  end
end
