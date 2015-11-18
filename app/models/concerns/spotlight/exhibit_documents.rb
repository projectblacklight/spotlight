module Spotlight
  # Mixin for retrieving solr documents for a specific exhibit
  module ExhibitDocuments
    ##
    # Retrieve all the solr documents associated with this exhibit, appropriately
    # filtered by the exhibit-specific solr field.
    #
    # @return [Enumerable<SolrDocument>]
    def solr_documents
      return to_enum(:solr_documents) unless block_given?

      start = 0
      response = repository.search(exhibit_search_params.merge(start: start))

      while response.documents.present?
        response.documents.each { |x| yield x }
        start += response.documents.length
        response = repository.search(exhibit_search_params.merge(start: start))
      end
    end

    private

    def exhibit_search_params
      params = { q: '*:*', fl: '*' }
      params[:fq] ||= []
      params[:fq] << solr_data if Spotlight::Engine.config.filter_resources_by_exhibit
      params
    end

    def repository
      @repository ||= Blacklight.repository_class.new(blacklight_config) if Blacklight.respond_to? :repository_class
      @repository ||= Blacklight::Solr::Repository.new(blacklight_config)
    end
  end
end
