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
      search_params = exhibit_search_builder.merge(q: '*:*', fl: '*')

      response = repository.search(search_params.start(start).to_h)

      while response.documents.present?
        response.documents.each { |x| yield x }
        start += response.documents.length
        response = repository.search(search_params.start(start).to_h)
      end
    end

    private

    def exhibit_search_builder
      blacklight_config.search_builder_class.new(true, exhibit_search_builder_context).except(:apply_permissive_visibility_filter)
    end

    def exhibit_search_builder_context
      OpenStruct.new(blacklight_config: blacklight_config, current_exhibit: self)
    end

    def repository
      @repository ||= Blacklight.repository_class.new(blacklight_config) if Blacklight.respond_to? :repository_class
      @repository ||= Blacklight::Solr::Repository.new(blacklight_config)
    end
  end
end
