module SirTrevorRails::Blocks
  class SolrDocumentsBlock < SirTrevorRails::Block

    attr_reader :solr_helper
  
    def with_solr_helper solr_helper
      @solr_helper = solr_helper
    end

    def document_options id
      (items.find { |x| x[:id] == id }) || {}
    end

    def documents
      @documents ||= begin
        doc_ids = items.map { |v| v[:id] }
        _, documents = solr_helper.fetch(doc_ids)
        documents.sort { |a,b| document_order.index(a.id) <=> document_order.index(b.id) }
      end
    end

    def documents?
      documents.present?
    end

    def text?
      text.present?
    end

    def text
      val = super

      # empty, in sir-trevor speak
      unless val == "<p><br></p>"
        val
      end
    end

    def items
      (item || {}).values.select { |x| x[:display] == "true" }
    end

    def document_order
      items.sort_by { |x| x[:weight] }.map { |x| x[:id] }
    end

    def text_align
      send(:'text-align')
    end

    def primary_caption?
      primary_caption_field.present? && send(:'show-primary-caption')
    end

    def secondary_caption?
      secondary_caption_field.present? && send(:'show-secondary-caption')
    end

    def primary_caption_field
      val = send(:'primary-caption-field')
      unless val.blank?
        val
      end
    end

    def secondary_caption_field
      val = send(:'secondary-caption-field')
      unless val.blank?
        val
      end
    end
  end
end