# frozen_string_literal: true

module Spotlight
  module Resources
    # transforms a IiifHarvester into solr documents
    class IiifBuilder < Spotlight::SolrDocumentBuilder
      def size
        0
      end

      def to_solr_document(manifest)
        manifest.with_exhibit(exhibit)
        manifest.to_solr
      end
    end
  end
end
