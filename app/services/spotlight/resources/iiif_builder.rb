# frozen_string_literal: true

module Spotlight
  module Resources
    # transforms a IiifHarvester into solr documents
    class IiifBuilder < Spotlight::SolrDocumentBuilder
      def to_solr
        return to_enum(:to_solr) { 0 } unless block_given?

        base_doc = super
        resource.iiif_manifests.each do |manifest|
          manifest.with_exhibit(exhibit)
          manifest_solr = manifest.to_solr
          yield base_doc.merge(manifest_solr) if manifest_solr.present?
        end
      end
    end
  end
end
