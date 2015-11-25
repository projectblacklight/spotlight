module Spotlight
  module SolrDocument
    ##
    # Finder methods for SolrDocuments
    module Finder
      extend ActiveSupport::Concern

      ##
      # Class level finder methods for documents
      module ClassMethods
        def find(id)
          solr_response = index.find(id)
          solr_response.documents.first
        end

        def index
          @index ||= blacklight_config.repository_class.new(blacklight_config)
        end

        def find_each
          return to_enum(:find_each) unless block_given?

          start = 0
          search_params = { q: '*:*', fl: 'id', facet: false }
          response = index.search(search_params.merge(start: start))

          while response.documents.present?
            response.documents.each { |x| yield x }
            start += response.documents.length
            response = index.search(search_params.merge(start: start))
          end
        end

        protected

        def blacklight_config
          @conf ||= Spotlight::Engine.blacklight_config
        end
      end

      def blacklight_solr
        self.class.index.connection
      end
    end
  end
end
