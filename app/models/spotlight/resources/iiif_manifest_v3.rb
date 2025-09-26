# frozen_string_literal: true

module Spotlight
  module Resources
    # A PORO to construct a solr hash for a given v3 IiifManifest
    class IiifManifestV3 < Spotlight::Resources::IiifManifest
      private

      def add_thumbnail_url
        return unless thumbnail_field && manifest['thumbnail'].present?

        solr_hash[thumbnail_field] = manifest.thumbnail.map(&:id)
      end

      def image_urls
        resources.map do |resource|
          image_url = (resource['id'] || resource['@id']).dup # break reference, otherwise it changes values of other fields
          image_url << '/info.json' unless image_url.downcase.ends_with?('/info.json')
          image_url
        end
      end

      def full_image_url
        resources.first.try(:[], 'id') || resources.first.try(:[], '@id')
      end

      def resources
        @resources ||=
          canvases
          .flat_map(&:items).select { |item| item.type == 'AnnotationPage' }
          .flat_map(&:items).select { |item| item.motivation == 'painting' }
          .flat_map(&:body)
          .flat_map(&:service)
      end

      def canvases
        manifest.try(:items).select { |canvas| canvas.type == 'Canvas' }
      end
    end
  end
end
