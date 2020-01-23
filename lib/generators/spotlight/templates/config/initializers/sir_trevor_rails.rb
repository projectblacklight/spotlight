# frozen_string_literal: true

# Required for 0.6 and up:
# https://github.com/madebymany/sir-trevor-rails#upgrade-guide-to-v060
class SirTrevorRails::Block
  def self.custom_block_types
    %w[
      Browse
      FeaturedPages
      Heading
      Iframe
      LinkToSearch
      List
      Oembed
      Quote
      Rule
      SearchResults
      SolrDocuments
      SolrDocumentsCarousel
      SolrDocumentsEmbed
      SolrDocumentsFeatures
      SolrDocumentsGrid
      Text
      UploadedItems
      Video
    ]
  end
end
