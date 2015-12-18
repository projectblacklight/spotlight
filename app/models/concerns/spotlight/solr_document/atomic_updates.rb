module Spotlight
  module SolrDocument
    ##
    # Solr indexing strategy using Solr's Atomic Updates
    module AtomicUpdates
      def reindex
        return unless write?
        data = hash_for_solr_update(to_solr)

        blacklight_solr.update params: { commitWithin: 500 }, data: data.to_json, headers: { 'Content-Type' => 'application/json' } unless data.empty?
      end

      def write?
        Spotlight::Engine.config.writable_index
      end

      private

      def hash_for_solr_update(data)
        Array.wrap(data).map { |doc| convert_document_to_atomic_update_hash(doc) }.reject { |x| x.length <= 1 }
      end

      def convert_document_to_atomic_update_hash(doc)
        doc.each_with_object({}) do |(k, v), hash|
          hash[k] = if k.to_sym == self.class.unique_key.to_sym
                      v
                    else
                      { set: v }
                    end
        end
      end
    end
  end
end
