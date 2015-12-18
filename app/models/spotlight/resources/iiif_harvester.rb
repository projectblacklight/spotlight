require 'iiif/presentation'

module Spotlight
  module Resources
    # harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
    # Note: IIIF API : http://iiif.io/api/presentation/2.0
    class IiifHarvester < Spotlight::Resource
      self.weight = -5000

      validate :valid_url?

      def self.can_provide?(res)
        url_is_iiif?(res.url)
      end

      def self.url_is_iiif?(url)
        valid_content_types = ['application/json', 'application/ld+json']
        req = Faraday.head(url)
        return unless req.success?
        valid_content_types.any? do |valid_type|
          req.headers['content-type'].include?(valid_type)
        end
      end

      def valid_url?
        errors.add(:url, 'Invalid IIIF URL') unless self.class.url_is_iiif?(url)
      end

      def to_solr
        return to_enum(:to_solr) { 0 } unless block_given?

        base_doc = super
        iiif_manifests.each do |manifest|
          manifest.with_exhibit(exhibit)
          manifest_solr = manifest.to_solr
          yield base_doc.merge(manifest_solr) if manifest_solr.present?
        end
      end

      private

      def iiif_manifests
        @iiif_manifests ||= IiifService.parse(url)
      end
    end
  end
end
