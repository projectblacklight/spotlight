module SirTrevorRails::Blocks
  module SolrDocumentBlock
    extend ActiveSupport::Concern

    included do
      attr_reader :solr_helper
    end

    def with_solr_helper solr_helper
      @solr_helper = solr_helper
    end

    def primary_caption?
      send(:'show-primary-caption') and send(:'item-grid-primary-caption-field').present?
    end
    
    def secondary_caption?
      send(:'show-primary-caption') and send(:'item-grid-secondary-caption-field').present?
    end

    def block_objects 
      return enum_for(:block_objects) unless block_given?

      data = as_json[:data].stringify_keys

      ids = data.keys.select { |x| x =~ /^item-grid-id_\d+$/ and data[x].present? }.
          map { |x| x.scan(/^item-grid-id_(\d+)$/); $1 }.
          select { |x| data["item-grid-display_#{x}"] }

      @documents ||= begin
        doc_ids = ids.map { |id| data["item-grid-id_#{id}"] }
        _, documents = solr_helper.fetch(doc_ids)
        documents
      end

      ids.each do |id|
        obj = data.select { |k, v| k =~ /item-grid-.*_#{id}/ }
        obj = Hash[obj.map { |k, v| [k.sub(/^item-grid-/, '').sub(/_#{id}$/, ''), v] }]
        obj["solr_document"] = @documents.select { |x| x.id == obj['id'] }.first

        yield OpenStruct.new(obj) if obj["solr_document"]
      end
    end
  end
end