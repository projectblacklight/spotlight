# frozen_string_literal: true

module Spotlight
  module Resources
    ##
    # Exhibit-specific resources, created using uploaded and custom fields
    class Upload < Spotlight::Resource
      belongs_to :upload, class_name: 'Spotlight::FeaturedImage', optional: true, validate: true

      # we want to do this before reindexing
      after_create :update_document_sidecar

      def self.fields(exhibit)
        @fields ||= {}
        @fields[exhibit] ||= begin
          index_title_field = exhibit.blacklight_config.index.title_field
          title_field = Spotlight::Engine.config.upload_title_field ||
                        Spotlight::UploadFieldConfig.new(
                          field_name: index_title_field,
                          label: I18n.t(:"spotlight.search.fields.#{index_title_field}")
                        )
          [title_field] + exhibit.uploaded_resource_fields
        end
      end

      def self.indexing_pipeline
        @indexing_pipeline ||= super.dup.tap do |pipeline|
          pipeline.transforms = [
            ->(data, p) { data.merge({ p.context.document_model.unique_key.to_sym => p.source.compound_id }) },
            Spotlight::Etl::Transforms::SourceMethodTransform(:to_solr)
          ] + pipeline.transforms
        end
      end

      def compound_id
        "#{exhibit_id}-#{id}"
      end

      def sidecar
        @sidecar ||= document_model.new(id: compound_id).sidecar(exhibit)
      end

      def to_solr
        return {} unless upload&.file_present?

        dimensions = Spotlight::Engine.config.iiif_service.info(upload.id)

        {
          spotlight_full_image_width_ssm: dimensions.width,
          spotlight_full_image_height_ssm: dimensions.height,
          Spotlight::Engine.config.thumbnail_field => Spotlight::Engine.config.iiif_service.thumbnail_url(upload),
          Spotlight::Engine.config.iiif_manifest_field => Spotlight::Engine.config.iiif_service.manifest_url(exhibit, self)
        }
      end

      private

      def configured_fields
        self.class.fields(exhibit)
      end

      def update_document_sidecar
        sidecar.update(data: sidecar.data.merge(sidecar_update_data))
      end

      def sidecar_update_data
        custom_fields_data.merge('configured_fields' => configured_fields_data)
      end

      def custom_fields_data
        data.slice(*exhibit.custom_fields.map(&:slug).map(&:to_s)).compact_blank
      end

      def configured_fields_data
        data.slice(*configured_fields.map(&:field_name).map(&:to_s)).compact_blank
      end
    end
  end
end
