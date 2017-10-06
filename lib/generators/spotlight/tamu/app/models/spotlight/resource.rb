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
    has_many :solr_document_sidecars

    serialize :data, Hash

    after_index :commit
    after_index :touch_exhibit!

    after_destroy :cleanup_solr_record, :cleanup_featured_image

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
      Spotlight::ReindexJob.perform_later(self)
    end

    def document_model
      exhibit.blacklight_config.document_model if exhibit
    end

    concerning :Indexing do
      ##
      # Index the result of {#to_solr} into the index in batches of {#batch_size}
      #
      # @return [Integer] number of records indexed
      # rubocop:disable Metrics/MethodLength
      def reindex(reindexing_log_entry = nil)
        benchmark "Reindexing #{self} (batch size: #{batch_size})" do
          count = 0

          run_callbacks :index do
            document_builder.documents_to_index.each_slice(batch_size) do |batch|
              write_to_index(batch)
              count += batch.length
              reindexing_log_entry.update(items_reindexed_count: count) if reindexing_log_entry
            end

            count
          end
        end
      end
      # rubocop:enable Metrics/MethodLength

      def document_builder
        @document_builder ||= document_builder_class.new(self)
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

      def touch_exhibit!
        exhibit.touch
      end

      def write?
        Spotlight::Engine.config.writable_index
      end

      def cleanup_solr_record
        return if multiple_exhibit_solr_document
        blacklight_solr.delete_by_id(document_ids, params: { softCommit: true })
      end

      def cleanup_featured_image
        return if multiple_exhibit_solr_document
        featured_image = Spotlight::FeaturedImage.find(upload_id)
        featured_image.image.remove! if featured_image && featured_image.image
      end

      def multiple_exhibit_solr_document
        solr_document_sidecars.size > 1
      end

      def document_ids
        document_builder.documents_to_index.to_a.map { |y| y[:id] }
      end
    end
  end
end
