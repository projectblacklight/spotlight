# frozen_string_literal: true

module Spotlight
  module Resources
    class IiifManifestV3 < Spotlight::Resources::IiifManifest
      private

      def add_thumbnail_url
        return unless thumbnail_field && manifest['thumbnail'].present?

        solr_hash[thumbnail_field] = manifest.thumbnail.map(&:id)
      end

      def add_full_image_urls
        return unless full_image_field && full_image_url

        solr_hash[full_image_field] = full_image_url
      end

      def add_label
        return unless title_fields.present? && manifest&.label

        Array.wrap(title_fields).each do |field|
          solr_hash[field] = metadata_class.new(manifest).label
        end
      end

      def add_image_urls
        solr_hash[tile_source_field] = image_urls
      end

      def add_metadata
        solr_hash.merge!(manifest_metadata)
        sidecar.update(data: sidecar.data.merge(manifest_metadata))
      end

      def manifest_metadata
        metadata = metadata_class.new(manifest).to_solr
        return {} if metadata.blank?

        create_sidecars_for(*metadata.keys)

        metadata.each_with_object({}) do |(key, value), hash|
          next unless (field = exhibit_custom_fields[key])

          hash[field.field] = value
        end
      end

      def create_sidecars_for(*keys)
        missing_keys(keys).each do |k|
          exhibit.custom_fields.create! label: k, readonly_field: true
        end
        @exhibit_custom_fields = nil
      end

      def missing_keys(keys)
        custom_field_keys = exhibit_custom_fields.keys.map(&:downcase)
        keys.reject do |key|
          custom_field_keys.include?(key.downcase)
        end
      end

      def exhibit_custom_fields
        @exhibit_custom_fields ||= exhibit.custom_fields.index_by do |value|
          value.label
        end
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

      def sequences
        manifest.try(:sequences) || []
      end

      def thumbnail_field
        blacklight_config.index.thumbnail_field
      end

      def full_image_field
        Spotlight::Engine.config.full_image_field
      end

      def tile_source_field
        blacklight_config.show.tile_source_field
      end

      def title_fields
        Spotlight::Engine.config.iiif_title_fields || blacklight_config.index&.title_field
      end

      def sidecar
        @sidecar ||= document_model.new(id: compound_id).sidecar(exhibit)
      end

      def document_model
        exhibit.blacklight_config.document_model
      end

      def metadata_class
        Spotlight::Engine.config.iiif_metadata_class.call
      end
    end
  end
end
