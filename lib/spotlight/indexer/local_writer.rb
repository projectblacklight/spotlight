module Spotlight
  module Indexer
    class LocalWriter
      delegate :update, to: :solr

      def solr
        @solr ||=  RSolr.connect(Blacklight.solr_config)
      end

    end
  end
end
