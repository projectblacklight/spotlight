module Spotlight
  ##
  # Exhibit resources
  class Resource < ActiveRecord::Base
    include Spotlight::SolrDocument::AtomicUpdates
    extend ActiveModel::Callbacks
    define_model_callbacks :index

    class_attribute :providers
    class_attribute :weight

    belongs_to :exhibit
    serialize :data, Hash

    after_save :reindex

    around_index :reindex_with_lock

    after_index :update_index_time!

    def self.providers
      Spotlight::Engine.config.resource_providers
    end

    def self.class_for_resource(r)
      providers.select { |provider| provider.can_provide? r }.sort_by(&:weight).first
    end

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

    ##
    # Index the result of {#to_solr} into the index in batches of {#batch_size}
    def reindex
      run_callbacks :index do
        data = to_solr
        return if data.blank?

        data &&= [data] if data.is_a? Hash

        data.each_slice(batch_size) do |batch|
          blacklight_solr.update params: { commitWithin: 500 },
                                 data: batch.reject(&:blank?).map { |doc| doc.reverse_merge(existing_solr_doc_hash(doc[unique_key]) || {}) }.to_json,
                                 headers: { 'Content-Type' => 'application/json' }
        end
      end
    end

    def update_index_time!
      update_columns indexed_at: Time.current
    end

    def becomes_provider
      klass = Spotlight::Resource.class_for_resource(self)

      if klass
        self.becomes! klass
      else
        self
      end
    end

    def needs_provider?
      type.blank?
    end

    def save_and_commit
      save.tap do
        begin
          blacklight_solr.commit
        rescue => e
          Rails.logger.warn "Unable to commit to solr: #{e}"
        end
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
  end
end
