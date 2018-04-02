# encoding: utf-8
module Spotlight
  module Resources
    ##
    # Exhibit-specific resources, created using uploaded and custom fields
    class Upload < Spotlight::Resource
      belongs_to :upload, class_name: 'Spotlight::FeaturedImage', optional: true

      # we want to do this before reindexing
      after_create :update_document_sidecar

      self.document_builder_class = UploadSolrDocumentBuilder

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

      def compound_id
        "#{exhibit_id}-#{id}"
      end

      def sidecar
        @sidecar ||= document_model.new(id: compound_id).sidecar(exhibit)
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
        data.slice(*exhibit.custom_fields.map(&:field).map(&:to_s)).select { |_k, v| v.present? }
      end

      def configured_fields_data
        data.slice(*configured_fields.map(&:field_name).map(&:to_s)).select { |_k, v| v.present? }
      end
    end
  end
end
