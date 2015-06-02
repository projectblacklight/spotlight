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

      def each_document
        return to_enum(:each_document) unless block_given?

        items.each do |i|
          document = documents.detect { |doc| doc.id == i[:id] }
          yield i, document if document
        end
      end

      def documents
        @documents ||= begin
          doc_ids = items.map { |v| v[:id] }
          _, documents = solr_helper.fetch(doc_ids)
          documents
        end
      end

      def documents?
        each_document.any?
      end

      def items
        (item || {}).values.select { |x| x[:display] == 'true' }
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
