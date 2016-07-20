module Spotlight
  # Creates solr documents for the documents in a resource
  class SolrDocumentBuilder
    def initialize(resource)
      @resource = resource
    end

    attr_reader :resource
    delegate :exhibit, :document_model, to: :resource

    ##
    # @return an enumerator of all the indexable documents for this resource
    def documents_to_index
      data = to_solr
      return [] if data.blank?
      data &&= [data] if data.is_a? Hash

      return to_enum(:documents_to_index) { data.size } unless block_given?

      data.lazy.reject(&:blank?).each do |doc|
        yield doc.reverse_merge(existing_solr_doc_hash(doc[unique_key]) || {})
      end
    end

    protected

    ##
    # @abstract
    # Convert this resource into zero-to-many new solr documents. The data here
    # should be merged into the resource-specific {#to_solr} data.
    #
    # @return [Hash] a single solr document hash
    # @return [Enumerator<Hash>] multiple solr document hashes. This can be a
    #   simple array, or an lazy enumerator
    def to_solr
      (exhibit_specific_solr_data || {}).merge(spotlight_resource_metadata_for_solr || {})
    end

    private

    ##
    # Get any exhibit-specific metadata stored in e.g. sidecars, tags, etc
    # This needs the generated solr document
    def existing_solr_doc_hash(id)
      document_model.new(unique_key => id).to_solr if document_model && id.present?
    end

    def unique_key
      if document_model
        document_model.unique_key.to_sym
      else
        :id
      end
    end

    def exhibit_specific_solr_data
      exhibit.solr_data if exhibit
    end

    def spotlight_resource_metadata_for_solr
      {
        Spotlight::Engine.config.resource_global_id_field => (resource.to_global_id.to_s if resource.persisted?),
        document_model.resource_type_field => resource.class.to_s.tableize
      }
    end
  end
end
