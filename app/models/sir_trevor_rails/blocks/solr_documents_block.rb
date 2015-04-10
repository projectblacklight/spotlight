module SirTrevorRails
  module Blocks
    ##
    # Multi-up document viewer with text block
    class SolrDocumentsBlock < SirTrevorRails::Block
      include Textable
      attr_reader :solr_helper

      def with_solr_helper(solr_helper)
        @solr_helper = solr_helper
      end

      def document_options(id)
        (items.detect { |x| x[:id] == id }) || {}
      end

      def documents
        @documents ||= begin
          doc_ids = items.map { |v| v[:id] }
          _, documents = solr_helper.fetch(doc_ids)
          documents.sort { |a, b| document_order.index(a.id) <=> document_order.index(b.id) }
        end
      end

      def documents?
        documents.present?
      end

      def items
        (item || {}).values.select { |x| x[:display] == 'true' }
      end

      def document_order
        items.sort_by { |x| x[:weight] }.map { |x| x[:id] }
      end

      def primary_caption?
        primary_caption_field.present? && send(:'show-primary-caption')
      end

      def secondary_caption?
        secondary_caption_field.present? && send(:'show-secondary-caption')
      end

      def primary_caption_field
        val = send(:'primary-caption-field')
        val unless val.blank?
      end

      def secondary_caption_field
        val = send(:'secondary-caption-field')
        val unless val.blank?
      end
    end
  end
end
