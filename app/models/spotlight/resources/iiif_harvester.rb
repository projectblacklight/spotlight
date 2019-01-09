require 'iiif/presentation'

module Spotlight
  module Resources
    # harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
    # Note: IIIF API : http://iiif.io/api/presentation/2.0
    class IiifHarvester < Spotlight::Resource
      self.document_builder_class = Spotlight::Resources::IiifBuilder
      self.weight = -5000

      validate :valid_url?

      def iiif_manifests
        @iiif_manifests ||= IiifService.parse(url)
      end

      private

      def valid_url?
        errors.add(:url, 'Invalid IIIF URL') unless url_is_iiif?(url)
      end

      def url_is_iiif?(url)
        valid_content_types = ['application/json', 'application/ld+json']
        req = Faraday.head(url)
        req = Faraday.get(url) if req.status == 405
        return unless req.success?

        valid_content_types.any? do |valid_type|
          req.headers['content-type'].include?(valid_type)
        end
      end
    end
  end
end
