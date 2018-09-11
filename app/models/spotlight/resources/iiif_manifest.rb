module Spotlight
  module Resources
    ##
    # A PORO to construct a solr hash for a given IiifManifest
    class IiifManifest
      attr_reader :collection
      def initialize(attrs = {})
        @url = attrs[:url]
        @manifest = attrs[:manifest]
        @collection = attrs[:collection]
        @solr_hash = {}
      end

      def to_solr
        add_document_id
        add_label
        add_thumbnail_url
        add_full_image_urls
        add_manifest_url
        add_image_urls
        add_metadata
        add_collection_id
        solr_hash
      end

      def with_exhibit(e)
        @exhibit = e
      end

      def compound_id
        Digest::MD5.hexdigest("#{exhibit.id}-#{url}")
      end

      private

      attr_reader :url, :manifest, :exhibit, :solr_hash
      delegate :blacklight_config, to: :exhibit

      def add_document_id
        solr_hash[exhibit.blacklight_config.document_model.unique_key.to_sym] = compound_id
      end

      def add_collection_id
        solr_hash[collection_id_field] = [collection.compound_id] if collection
      end

      def collection_id_field
        Spotlight::Engine.config.iiif_collection_id_field
      end

      def add_manifest_url
        solr_hash[Spotlight::Engine.config.iiif_manifest_field] = url
      end

      def add_thumbnail_url
        return unless thumbnail_field && manifest['thumbnail'].present?

        solr_hash[thumbnail_field] = manifest['thumbnail']['@id']
      end

      def add_full_image_urls
        return unless full_image_field && full_image_url

        solr_hash[full_image_field] = full_image_url
      end

      def add_label
        return unless title_fields.present? && manifest.try(:label)

        Array.wrap(title_fields).each do |field|
          solr_hash[field] = json_ld_value(manifest.label)
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
        return {} unless metadata.present?

        create_sidecars_for(*metadata.keys)

        metadata.each_with_object({}) do |(key, value), hash|
          next unless (field = exhibit_custom_fields[key])

          hash[field.field] = value
        end
      end

      def json_ld_value(value)
        return value['@value'] if value.is_a?(Hash)
        return value.find { |v| v['@language'] == default_json_ld_language }.try(:[], '@value') if value.is_a?(Array)

        value
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
        @exhibit_custom_fields ||= exhibit.custom_fields.each_with_object({}) do |value, hash|
          hash[value.label] = value
        end
      end

      def image_urls
        @image_urls ||= resources.map do |resource|
          next unless resource && !resource.service.empty?

          image_url = resource.service['@id']
          image_url << '/info.json' unless image_url.downcase.ends_with?('/info.json')
          image_url
        end
      end

      def full_image_url
        resources.first.try(:[], '@id')
      end

      def resources
        @resources ||= sequences
                       .flat_map(&:canvases)
                       .flat_map(&:images)
                       .flat_map(&:resource)
      end

      def sequences
        manifest.try(:sequences) || []
      end

      def thumbnail_field
        blacklight_config.index.try(:thumbnail_field)
      end

      def full_image_field
        Spotlight::Engine.config.full_image_field
      end

      def tile_source_field
        blacklight_config.show.try(:tile_source_field)
      end

      def title_fields
        Spotlight::Engine.config.iiif_title_fields || blacklight_config.index.try(:title_field)
      end

      def default_json_ld_language
        Spotlight::Engine.config.default_json_ld_language
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

      ###
      #  A simple class to map the metadata field
      #  in a IIIF document to label/value pairs
      #  This is intended to be overriden by an
      #  application if a different metadata
      #  strucure is used by the consumer
      class Metadata
        def initialize(manifest)
          @manifest = manifest
        end

        def to_solr
          metadata_hash.merge(manifest_level_metadata)
        end

        private

        attr_reader :manifest

        def metadata
          manifest.try(:metadata) || []
        end

        def metadata_hash
          return {} unless metadata.present?
          return {} unless metadata.is_a?(Array)

          metadata.each_with_object({}) do |md, hash|
            next unless md['label'] && md['value']

            hash[md['label']] ||= []
            hash[md['label']] += Array(md['value'])
          end
        end

        def manifest_level_metadata
          manifest_fields.each_with_object({}) do |field, hash|
            next unless manifest.respond_to?(field) &&
                        manifest.send(field).present?

            hash[field.capitalize] ||= []
            hash[field.capitalize] += Array(manifest.send(field))
          end
        end

        def manifest_fields
          %w(attribution description license)
        end
      end
    end
  end
end
