module Spotlight
  module Resources
    ###
    #  A simple class to map the metadata field
    #  in a IIIF document to label/value pairs
    #  This is intended to be overriden by an
    #  application if a different metadata
    #  strucure is used by the consumer
    class IiifManifest::Metadata
      def initialize(manifest)
        @manifest = manifest
      end

      def to_solr
        metadata_hash.merge(manifest_level_metadata)
      end

      def label
        return unless manifest&.label

        Array(json_ld_value(manifest.label)).map { |v| html_sanitize(v) }.first
      end

      private

      attr_reader :manifest

      def metadata
        manifest&.metadata || []
      end

      def metadata_hash
        return {} if metadata.blank?
        return {} unless metadata.is_a?(Array)

        metadata.each_with_object({}) do |md, hash|
          next unless md['label'] && md['value']

          label = Array(json_ld_value(md['label'])).first

          hash[label] ||= []
          hash[label] += Array(json_ld_value(md['value'])).map { |v| html_sanitize(v) }
        end
      end

      def manifest_level_metadata
        return manifest_level_metadata_v2 unless manifest_level_metadata_v2.empty?

        manifest_level_metadata_v3
      end

      def manifest_level_metadata_v2
        @manifest_level_metadata_v2 ||=
          manifest2_fields.each_with_object({}) do |field, hash|
            next unless manifest.respond_to?(field) && manifest.send(field).present?

            hash[field.capitalize] ||= []
            hash[field.capitalize] += Array(json_ld_value(manifest.send(field))).map { |v| html_sanitize(v) }
          end
      end

      def manifest2_fields
        %w[attribution description license]
      end

      def manifest_level_metadata_v3
        manifest3_fields.each_with_object({}) do |field, hash|
          manifest_key, solr_key = field
          next unless manifest.respond_to?(manifest_key) && manifest.send(manifest_key).present?

          hash[solr_key.capitalize] ||= []
          hash[solr_key.capitalize] += Array(json_ld_value(manifest.send(manifest_key))).map { |v| html_sanitize(v) }
        end.merge(attribution_v3)
      end

      def manifest3_fields
        { rights: 'license', summary: 'description' }
      end

      def attribution_v3
        rs = manifest['required_statement']
        return {} if rs.blank?

        key = json_ld_value(rs['label']).first
        val = json_ld_value(rs['value'])
        { key => val }
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      def json_ld_value(value)
        case value
          # In the case where multiple values are supplied, clients must use the following algorithm to determine which values to display to the user.
        when Array
          # IIIF v2, multivalued monolingual, or multivalued multilingual values

          # If none of the values have a language associated with them, the client must display all of the values.
          if value.none? { |v| v.is_a?(Hash) && v.key?('@language') }
            value.map { |v| json_ld_value(v) }
            # If any of the values have a language associated with them, the client must display all of the values associated with the language that best
            # matches the language preference.
          elsif value.any? { |v| v.is_a?(Hash) && v['@language'] == default_json_ld_language }
            value.select { |v| v.is_a?(Hash) && v['@language'] == default_json_ld_language }.pluck('@value')
            # If all of the values have a language associated with them, and none match the language preference, the client must select a language
            # and display all of the values associated with that language.
          elsif value.all? { |v| v.is_a?(Hash) && v.key?('@language') }
            selected_json_ld_language = value.find { |v| v.is_a?(Hash) && v.key?('@language') }

            value.select { |v| v.is_a?(Hash) && v['@language'] == selected_json_ld_language['@language'] }
                 .pluck('@value')
            # If some of the values have a language associated with them, but none match the language preference, the client must display all of the values
            # that do not have a language associated with them.
          else
            value.select { |v| !v.is_a?(Hash) || !v.key?('@language') }.map { |v| json_ld_value(v) }
          end
        when Hash
          # IIIF v2 single-valued value
          if value.key? '@value'
            value['@value']
            # IIIF v3 multilingual(?), multivalued(?) values
            # If all of the values are associated with the none key, the client must display all of those values.
          elsif value.keys == ['none']
            value['none']
            # If any of the values have a language associated with them, the client must display all of the values associated with the language
            # that best matches the language preference.
          elsif value.key? default_json_ld_language
            value[default_json_ld_language]
            # If some of the values have a language associated with them, but none match the language preference, the client must display all
            # of the values that do not have a language associated with them.
          elsif value.key? 'none'
            value['none']
            # If all of the values have a language associated with them, and none match the language preference, the client must select a
            # language and display all of the values associated with that language.
          else
            value.values.first
          end
        else
          # plain old string/number/boolean
          value
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity

      def html_sanitize(value)
        return value unless value.is_a? String

        html_sanitizer.sanitize(value)
      end

      def html_sanitizer
        @html_sanitizer ||= Rails::Html::FullSanitizer.new
      end

      def default_json_ld_language
        Spotlight::Engine.config.default_json_ld_language
      end
    end
  end
end
