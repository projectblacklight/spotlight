# frozen_string_literal: true

module Spotlight
  # Service that is initilized with a SolrDocument from an item in spotlight and
  # returns the IIIF manifest URL
  class ManifestService
    attr_reader :document

    # @param document [SolrDocument] a SolrDocument from an item in Spotlight with a IIIF manifest
    def initialize(document:)
      @document = document
    end

    # @return [String] the URL to a IIIF manifest
    def url
      document.response.dig(:response, :docs, 0, :iiif_manifest_url_ssi)
    end
  end
end
