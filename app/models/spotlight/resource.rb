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
      :last_index_elapsed_time], coder: JSON

    around_index :reindex_with_lock
    around_index :reindex_with_logging
    after_index :commit

    ##
    # @abstract
    # Convert this resource into zero-to-many new solr documents. The data here
    # should be merged into the resource-specific {#to_solr} data.
    #
    # @return [Hash] a single solr document hash
    # @return [Enumerator<Hash>] multiple solr document hashes. This can be a
    #   simple array, or an lazy enumerator
    def to_solr
      (exhibit_specific_solr_data || {})
        .merge(spotlight_resource_metadata_for_solr || {})
    end

    def self.resource_global_id_field
      :"#{Spotlight::Engine.config.solr_fields.prefix}spotlight_resource_id#{Spotlight::Engine.config.solr_fields.string_suffix}"
    end

    def reindex_with_lock
      with_lock do
        yield
      end
    end

    def reindex_with_logging
      time_start = Time.zone.now

      count = yield

      time_end = Time.zone.now

      update(indexed_at: Time.current,
             last_indexed_estimate: documents_to_index.size,
             last_indexed_count: count,
             last_index_elapsed_time: time_end - time_start)
    end

    ##
    # Index the result of {#to_solr} into the index in batches of {#batch_size}
    #
    # @return [Integer] number of records indexed
    def reindex
      benchmark "Reindexing #{self} (batch size: #{batch_size})" do
        count = 0

        run_callbacks :index do
          documents_to_index.each_slice(batch_size) do |batch|
            add_to_index(batch)
            count += batch.length
          end

          count
        end
      end
    end

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

    def save_and_index
      save.tap do
        reindex
      end
    end

    protected

    def blacklight_solr
      @solr ||= RSolr.connect(connection_config)
    end

    def connection_config
      Blacklight.connection_config
    end

    def document_model
      exhibit.blacklight_config.document_model if exhibit
    end

    def batch_size
      Spotlight::Engine.config.solr_batch_size
    end

    def exhibit_specific_solr_data
      exhibit.solr_data if exhibit
    end

    def spotlight_resource_metadata_for_solr
      {
        Spotlight::Resource.resource_global_id_field => (to_global_id.to_s if persisted?),
        Spotlight::SolrDocument.resource_type_field => self.class.to_s.tableize
      }
    end

    ##
    # @return an enumerator of all the indexable documents for this resource
    def documents_to_index
      data = to_solr
      return [] if data.blank?
      data &&= [data] if data.is_a? Hash

      return to_enum(:documents_to_index) { data.size } unless block_given?

      data.reject(&:blank?).each do |doc|
        yield doc.reverse_merge(existing_solr_doc_hash(doc[unique_key]) || {})
      end
    end

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

    def add_to_index(batch)
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
