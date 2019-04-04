# frozen_string_literal: true

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
        [uploaded_resource.upload.iiif_tilesource] if uploaded_resource && uploaded_resource.upload
      end
    end
  end
end
