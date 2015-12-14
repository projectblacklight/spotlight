module Spotlight
  ##
  # Exhibit resources
  class Resource < ActiveRecord::Base
    include Spotlight::SolrDocument::AtomicUpdates
    include ActiveSupport::Benchmarkable

    extend ActiveModel::Callbacks
    define_model_callbacks :index

    class_attribute :weight

    belongs_to :exhibit
    serialize :data, Hash
    store :metadata, accessors: [
      :last_indexed_estimate,
      :last_indexed_count,
      :last_index_elapsed_time,
      :last_indexed_finished], coder: JSON

    enum index_status: [:waiting, :completed, :errored]

    around_index :reindex_with_logging
    after_index :commit
    after_index :completed!

    def becomes_provider
      klass = Spotlight::ResourceProvider.for_resource(self)

      if klass
        self.becomes! klass
      else
        self
      end
    end

    def needs_provider?
      type.blank?
    end

    ##
    # Persist the record to the database, and trigger a reindex to solr
    #
    # @param [Hash] All arguments will be passed through to ActiveRecord's #save method
    def save_and_index(*args)
      save(*args) && reindex_later
    end

    ##
    # Enqueue an asynchronous reindexing job for this resource
    def reindex_later
      waiting!
      Spotlight::ReindexJob.perform_later(self)
    end

    concerning :GeneratingSolrDocuments do
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

      protected

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
          Spotlight::Engine.config.resource_global_id_field => (to_global_id.to_s if persisted?),
          document_model.resource_type_field => self.class.to_s.tableize
        }
      end

      def document_model
        exhibit.blacklight_config.document_model if exhibit
      end
    end

    concerning :Indexing do
      ##
      # Index the result of {#to_solr} into the index in batches of {#batch_size}
      #
      # @return [Integer] number of records indexed
      def reindex
        benchmark "Reindexing #{self} (batch size: #{batch_size})" do
          count = 0

          run_callbacks :index do
            documents_to_index.each_slice(batch_size) do |batch|
              write_to_index(batch)
              update(last_indexed_count: (count += batch.length))
            end

            count
          end
        end
      end

      protected

      def reindex_with_logging
        time_start = Time.zone.now

        update(indexed_at: time_start,
               last_indexed_estimate: documents_to_index.size,
               last_indexed_finished: nil,
               last_index_elapsed_time: nil)

        count = yield

        time_end = Time.zone.now
        update(last_indexed_count: count,
               last_indexed_finished: time_end,
               last_index_elapsed_time: time_end - time_start)
      end

      private

      def blacklight_solr
        @solr ||= RSolr.connect(connection_config)
      end

      def connection_config
        Blacklight.connection_config
      end

      def batch_size
        Spotlight::Engine.config.solr_batch_size
      end

      def write_to_index(batch)
        blacklight_solr.update params: { commitWithin: 500 },
                               data: batch.to_json,
                               headers: { 'Content-Type' => 'application/json' }
      end

      def commit
        blacklight_solr.commit
      rescue => e
        Rails.logger.warn "Unable to commit to solr: #{e}"
      end
    end
  end
end
