module Spotlight
  module SolrDocument
    ##
    # Mixin for SolrDocuments backed by exhibit-specific resources
    module UploadedResource
      extend ActiveSupport::Concern

      included do
        accepts_nested_attributes_for :uploaded_resource
      end

      def uploaded_resource
        @uploaded_resource ||= GlobalID::Locator.locate first(Spotlight::Engine.config.resource_global_id_field)
      rescue => e
        Rails.logger.info("Unable to locate uploaded resource: #{e}")
        nil
      end

      def to_openseadragon(*_args)
        self[Spotlight::Engine.config.full_image_field].each_with_index.map do |image_url, index|
          { LegacyImagePyramidTileSource.new(
            image_url,
            width: self[:spotlight_full_image_width_ssm][index],
            height: self[:spotlight_full_image_height_ssm][index]
          ) => {}
          }
        end
      end

      ##
      # Stub legacy image pyramid property generators
      class LegacyImagePyramidTileSource
        attr_reader :to_tilesource
        def initialize(url, dimensions = {})
          @to_tilesource = {
            type: 'legacy-image-pyramid',
            levels: [{
              url: url,
              width: dimensions[:width],
              height: dimensions[:height]
            }]
          }
        end
      end
    end
  end
end
