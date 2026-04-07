# frozen_string_literal: true

module Spotlight
  module PageContent
    class EditorJs
      ##
      # Backend block model for the custom "solr_documents" Editor.js tool.
      #
      # Mirrors the behaviour of SirTrevorRails::Blocks::SolrDocumentsBlock but
      # consumes the flatter data shape produced by SolrDocumentsTool:
      #
      #   {
      #     "items": [
      #       { "id": "...", "title": "...", "display": true, "weight": 0,
      #         "thumbnail_image_url": "...", "iiif_tilesource": "...", ... }
      #     ],
      #     "show_primary_caption":    true,
      #     "primary_caption_field":   "field_key",
      #     "show_secondary_caption":  false,
      #     "secondary_caption_field": "",
      #     "zpr_link":                false
      #   }
      #
      class SolrDocumentsBlock < Block
        attr_reader :solr_helper

        # Called from the view (mirroring the Sir Trevor convention).
        def with_solr_helper(solr_helper)
          @solr_helper = solr_helper
          self
        end

        # Items that have been marked for display, sorted by saved weight.
        def items
          raw = @data['items'] || []
          raw.select { |i| i['display'] }
             .sort_by { |i| i['weight'].to_i }
             .map(&:with_indifferent_access)
        end

        def each_document
          return to_enum(:each_document) unless block_given?

          items.each do |item|
            document = documents.detect { |doc| doc.id == item['id'] }
            next unless document

            item['iiif_tilesource_base'] = item['iiif_tilesource'].to_s.sub('/info.json', '')
            yield item, document
          end
        end

        def documents
          @documents ||= begin
            ids    = items.pluck('id')
            result = solr_helper.controller.send(:search_service).fetch(ids)
            # search_service.fetch can return either a [Response, docs] pair or
            # the docs collection directly depending on the Blacklight version.
            # Coerce to a plain Array so callers can safely use Enumerable methods.
            docs = result.first.is_a?(Blacklight::Solr::Response) ? result.last : result
            Array(docs)
          end
        end

        def documents?
          each_document.any?
        end

        # ----- Caption helpers -----------------------------------------------

        def primary_caption?
          @data['show_primary_caption'] && primary_caption_field.present?
        end

        def secondary_caption?
          @data['show_secondary_caption'] && secondary_caption_field.present?
        end

        def primary_caption_field
          @data['primary_caption_field'].presence
        end

        def secondary_caption_field
          @data['secondary_caption_field'].presence
        end

        def document_caption(presenter, caption_field)
          return unless caption_field
          return presenter.heading if caption_field == Spotlight::PageConfigurations::DOCUMENT_TITLE_KEY

          presenter.field_value(
            solr_helper.blacklight_config.index_fields[caption_field] ||
            null_display_field(caption_field)
          )
        end

        # ----- ZPR -----------------------------------------------------------

        def zpr_link?
          @data['zpr_link'] == true
        end

        private

        def null_display_field(field)
          if defined?(Blacklight::Configuration::NullDisplayField)
            Blacklight::Configuration::NullDisplayField.new(field)
          else
            Blacklight::Configuration::NullField.new(field)
          end
        end
      end
    end
  end
end
