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
        yield doc.reverse_merge(exhibit_solr_doc(doc[unique_key]).to_solr)
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
      spotlight_resource_metadata_for_solr
    end

    private

    # Null object for SolrDocument
    module NilSolrDocument
      def self.to_solr
        {}
      end
    end

    ##
    # Get any exhibit-specific metadata stored in e.g. sidecars, tags, etc
    # This needs the generated solr document
    # @returns [#to_solr] something that responds to `to_solr'
    def exhibit_solr_doc(id)
      return NilSolrDocument unless document_model || id.present?

      document_model.build_for_exhibit(id, exhibit, resource: resource)
    end

    def unique_key
      if document_model
        document_model.unique_key.to_sym
      else
        :id
      end
    end

    def spotlight_resource_metadata_for_solr
      {
        Spotlight::Engine.config.resource_global_id_field => (resource.to_global_id.to_s if resource.persisted?),
        document_model.resource_type_field => resource.class.to_s.tableize
      }
    end
  end
end
