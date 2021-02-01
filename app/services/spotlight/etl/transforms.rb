# frozen_string_literal: true

module Spotlight
  module Etl
    # Basic + default transform steps
    module Transforms
      # A transform step that "transforms" the source into the data element
      IdentityTransform = lambda do |data, pipeline|
        data.merge(pipeline.source)
      end

      # A transform step that calls a method on the source to generate a document
      def self.SourceMethodTransform(method) # rubocop:disable Naming/MethodName
        lambda do |data, pipeline|
          data.merge(pipeline.source.public_send(method))
        end
      end

      # A transform step that throws away blank data
      RejectBlank = lambda do |data, _|
        throw :skip if data.blank?
        data
      end

      # A trasnform step that ensures data has a unique key attribute
      RejectMissingUniqueId = lambda do |data, pipeline|
        id = pipeline.context.unique_key(data)

        throw :skip if id.blank?
        data
      end

      # A transform that adds exhibit-specific metadata (like Spotlight sidecar data)
      # to the document
      ApplyExhibitMetadata = lambda do |data, pipeline|
        resource = pipeline.context.resource
        document_model = pipeline.context.document_model
        id = pipeline.context.unique_key(data)

        next data unless document_model && id.present?

        exhibit_metadata = document_model.build_for_exhibit(id, resource.exhibit, resource: (resource if resource.persisted?))

        data.reverse_merge(exhibit_metadata.to_solr)
      end

      # A transform that adds application-specific metadata (like what resource generated the solr document)
      ApplyApplicationMetadata = lambda do |data, pipeline|
        resource = pipeline.context.resource
        document_model = pipeline.context.document_model

        data.reverse_merge(
          Spotlight::Engine.config.resource_global_id_field => (resource.to_global_id.to_s if resource.persisted?),
          document_model.resource_type_field => resource.class.to_s.tableize
        )
      end

      # A transform that adds externally-provided metadata to the document
      ApplyPipelineMetadata = lambda do |data, pipeline|
        data.reverse_merge(pipeline.context.additional_metadata)
      end
    end
  end
end
