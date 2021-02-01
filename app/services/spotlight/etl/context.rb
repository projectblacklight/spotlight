# frozen_string_literal: true

module Spotlight
  module Etl
    # Contextual information for the ETL pipeline
    class Context
      # A hook for downstream applications to report or handle errors using external
      # systems or services.
      class_attribute :error_reporter

      attr_reader :arguments, :additional_metadata, :additional_parameters, :logger

      delegate :document_model, to: :resource

      def initialize(*args, additional_metadata: {}, on_error: :log, logger: Rails.logger, **additional_parameters)
        @arguments = args
        @additional_metadata = additional_metadata
        @additional_parameters = additional_parameters
        @on_error = on_error
        @logger = logger
      end

      # @return [Spotlight::Resource]
      def resource
        arguments.first
      end

      # @return [String]
      def unique_key(data)
        data[document_model&.unique_key&.to_sym || :id]
      end

      ##
      # This hook receives any exceptions raised by pipeline steps and handles them
      # appropriately.
      def on_error(pipeline, exception, data)
        error_reporter&.call(pipeline, exception, data)

        case @on_error
        when :log
          logger.tagged('ETL') do
            logger.error("Pipeline error processing resource #{resource.id}: #{exception}")
          end
        when :exception
          raise exception
        else
          @on_error&.call(pipeline, exception, data)
        end
      end
    end
  end
end
