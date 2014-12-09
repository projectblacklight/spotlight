module Spotlight::SolrDocument
  module Finder
    
    extend ActiveSupport::Concern

    module ClassMethods
      def find(id)
        solr_params = {id: id, qt: 'document'}
        solr_response = get_solr_response(solr_params)
        raise Blacklight::Exceptions::InvalidSolrID, "Can't find #{id}" if solr_response.docs.empty?
        new(solr_response.docs.first, solr_response)
      end

      def blacklight_solr
        @solr ||=  RSolr.connect(blacklight_solr_config)
      end

      protected 

      def get_solr_response(params)
        path = blacklight_config.solr_path
        response = blacklight_solr.get(path, :params=> params)
        Blacklight::SolrResponse.new(response, params)
      rescue Errno::ECONNREFUSED => e
        raise Blacklight::Exceptions::ECONNREFUSED.new("Unable to connect to Solr instance using #{blacklight_solr.inspect}")
      end

      def blacklight_config
        @conf ||= CatalogController.blacklight_config
      end

      def blacklight_solr_config
        Blacklight.solr_config
      end
    end

    def blacklight_solr
      self.class.blacklight_solr
    end
  end
end
