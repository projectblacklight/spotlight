# frozen_string_literal: true

module Spotlight
  module Etl
    # Solr data loader with a built-in buffer to combine document updates into batches
    class SolrLoader
      attr_reader :queue, :batch_size

      delegate :size, to: :queue

      def initialize(batch_size: Spotlight::Engine.config.solr_batch_size, solr_connection: nil)
        @queue = Queue.new
        @batch_size = batch_size
        @blacklight_solr = solr_connection
      end

      def call(data, pipeline = nil)
        @queue << data

        write_to_index(pipeline) if @queue.size >= @batch_size
      end

      def finalize(pipeline = nil)
        write_to_index(pipeline)

        commit! if pipeline.nil? || pipeline.context.additional_parameters[:commit]
      end

      private

      def write_to_index(pipeline)
        batch = drain_queue

        return unless write? && batch.any?

        send_batch(batch, pipeline)
      end

      def send_batch(documents, pipeline)
        blacklight_solr.update params: { commitWithin: 500 },
                               data: documents.to_json,
                               headers: { 'Content-Type' => 'application/json' }
      rescue StandardError => e
        logger.warn "Error sending a batch of documents to solr: #{e}"

        documents.each do |doc|
          send_one(doc, pipeline)
        end
      end

      def send_one(document, pipeline)
        blacklight_solr.update params: { commitWithin: 500 },
                               data: [document].to_json,
                               headers: { 'Content-Type' => 'application/json' }
      rescue StandardError => e
        pipeline&.on_error(e, document.to_json)
      end

      def blacklight_solr
        @blacklight_solr ||= RSolr.connect(connection_config.merge(adapter: connection_config[:http_adapter]))
      end

      def connection_config
        Blacklight.connection_config
      end

      def drain_queue
        arr = []

        begin
          arr << @queue.deq(true) while arr.length < @batch_size && !@queue.empty?
        rescue ThreadError
          # @queue throws a ThreadError if it is empty...
        end

        arr
      end

      def commit!
        return unless write?

        blacklight_solr.commit
      rescue StandardError => e
        logger.warn "Unable to commit to solr: #{e}"
      end

      def write?
        Spotlight::Engine.config.writable_index
      end

      def logger
        Rails.logger
      end
    end
  end
end
