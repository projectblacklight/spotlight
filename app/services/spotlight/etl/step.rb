# frozen_string_literal: true

module Spotlight
  module Etl
    # ETL pipeline step
    class Step
      attr_reader :definition, :context, :executor

      # @param [Class, Proc] definition the step to run
      # @param [String] label
      # @param [Spotlight::Etl::Executor] executor the execution environment
      def initialize(definition, label: nil, executor: nil)
        @definition = definition
        @executor = executor
        @label = label
      end

      # rubocop:disable Metrics/MethodLength
      def call(*args)
        with_logger do |logger|
          logger.debug { "Called with #{transform_data_for_debugging(args.first)}" }

          catch :skip do
            return action.call(*args).tap do |result|
              logger.debug { "   => Returning #{transform_data_for_debugging(result)}" } if $VERBOSE
            end
          end

          logger.debug '  => Caught skip.'
          throw :skip
        end
      rescue StandardError => e
        with_logger do |logger|
          logger.error("Caught exception #{e}")
        end
        raise(e)
      end
      # rubocop:enable Metrics/MethodLength

      def finalize(*args)
        action.finalize(*args) if action.respond_to? :finalize
      end

      private

      # @return [#call]
      def action
        case definition
        when Class
          # memoize the class' instance for the lifetime of the step
          @memoized_action ||= definition.new
        else # Proc, etc
          definition
        end
      end

      # @return [#to_string]
      def label
        @label || definition
      end

      # NOTE: this is super weird to support Rails 5.2
      # @return [Logger]
      def with_logger
        yield(Rails.logger) && return unless executor

        executor.with_logger do |logger|
          logger.tagged(label) do
            yield logger
          end
        end
      end

      ##
      # @param [Hash] data
      # @return [String] a simplified + truncated version of the data hash for debugging
      def transform_data_for_debugging(data)
        executor&.transform_data_for_debugging(data) || data.inspect.truncate(100)
      end
    end
  end
end
