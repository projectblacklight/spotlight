# frozen_string_literal: true

module Spotlight
  module Resources
    # Raw solr document uploads
    class JsonUpload < Spotlight::Resource
      store :data, accessors: :json

      # The indexing pipeline for JSON uploads copies the data from the stored
      # `#data` field directly into the indexed document.
      def self.indexing_pipeline
        @indexing_pipeline ||= super.dup.tap do |pipeline|
          pipeline.sources = [Spotlight::Etl::Sources::StoredData]

          pipeline.transforms = [
            Spotlight::Etl::Transforms::IdentityTransform
          ] + pipeline.transforms
        end
      end
    end
  end
end
