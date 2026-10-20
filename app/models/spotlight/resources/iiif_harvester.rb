# frozen_string_literal: true

require 'iiif/presentation'
require 'ssrf_filter'

module Spotlight
  module Resources
    # harvest Images from IIIF Manifest and turn them into a Spotlight::Resource
    # Note: IIIF API : http://iiif.io/api/presentation/2.0
    class IiifHarvester < Spotlight::Resource
      self.weight = -5000

      validate :valid_url?

      def iiif_manifests
        @iiif_manifests ||= IiifService.parse(url)
      end

      def self.indexing_pipeline
        @indexing_pipeline ||= super.dup.tap do |pipeline|
          pipeline.sources = [Spotlight::Etl::Sources::SourceMethodSource(:iiif_manifests)]

          pipeline.transforms = [
            ->(data, p) { data.merge(p.source.to_solr(exhibit: p.context.resource.exhibit)) }
          ] + pipeline.transforms
        end
      end

      private

      def valid_url?
        errors.add(:url, 'Invalid IIIF URL') unless url_is_iiif?(url)
      end

      def url_is_iiif?(url)
        valid_content_types = ['application/json', 'application/ld+json']
        req = SsrfFilter.head(url)
        req = SsrfFilter.get(url) if req.code == '405'
        return unless req.is_a?(Net::HTTPSuccess)

        valid_content_types.any? do |valid_type|
          req['content-type'].to_s.include?(valid_type)
        end
      rescue SsrfFilter::Error => e
        Rails.logger.warn("Refusing to fetch #{url}: #{e.message}")
        false
      end
    end
  end
end
