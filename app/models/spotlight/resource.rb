module Spotlight
  ##
  # Exhibit resources
  class Resource < ActiveRecord::Base
    include ActiveSupport::Benchmarkable

    class_attribute :document_builder_class
    self.document_builder_class = SolrDocumentBuilder

    extend ActiveModel::Callbacks
    define_model_callbacks :index

    class_attribute :weight

    belongs_to :exhibit
    serialize :data, Hash
    store :metadata, accessors: [
      :enqueued_at,
      :last_indexed_estimate,
      :last_indexed_count,
      :last_index_elapsed_time,
      :last_indexed_finished
    ], coder: JSON

    enum index_status: [:waiting, :completed, :errored]

    around_index :reindex_with_logging
    after_index :commit
    after_index :completed!

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

    def waiting!
      update(enqueued_at: Time.zone.now)
      super
    end

    def enqueued_at
      cast_to_date_time(super)
    end

    def enqueued_at?
      enqueued_at.present?
    end

    def last_indexed_finished
      cast_to_date_time(super)
    end

    def document_model
      exhibit.blacklight_config.document_model if exhibit
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
            document_builder.documents_to_index.each_slice(batch_size) do |batch|
              write_to_index(batch)
              update(last_indexed_count: (count += batch.length))
            end

            count
          end
        end
      end

      def document_builder
        @document_builder ||= document_builder_class.new(self)
      end

      protected

      def reindex_with_logging
        time_start = Time.zone.now

        update(indexed_at: time_start,
               last_indexed_estimate: document_builder.documents_to_index.size,
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
        return unless write?
        blacklight_solr.update params: { commitWithin: 500 },
                               data: batch.to_json,
                               headers: { 'Content-Type' => 'application/json' }
      end

      def commit
        return unless write?
        blacklight_solr.commit
      rescue => e
        Rails.logger.warn "Unable to commit to solr: #{e}"
      end

      def write?
        Spotlight::Engine.config.writable_index
      end

      def cast_to_date_time(value)
        return unless value

        if defined? ActiveModel::Type::DateTime
          ActiveModel::Type::DateTime.new.cast(value)
        else
          ActiveRecord::Type::DateTime.new.type_cast_from_database(value)
        end
      end
    end
  end
end
