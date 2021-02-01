# frozen_string_literal: true

module Spotlight
  module Etl
    # ETL pipeline executor
    class Executor
      include ActiveSupport::Benchmarkable

      attr_reader :pipeline, :context, :source, :cache, :logger

      delegate :sources, :pre_processes, :transforms, :post_processes, :loaders, to: :pipeline

      # @param [Spotlight::Etl::Pipeline] pipeline
      # @param [Spotlight::Etl::Context] context
      # @param [Hash] cache a shared cache for pipeline steps to store data for the lifetime of the cache
      def initialize(pipeline, context, cache: nil)
        @pipeline = pipeline
        @context = context

        @provided_cache = cache.present?
        @cache = cache || {}
        @step_cache = {}
      end

      ##
      # Execute the ETL pipeline
      #
      # @param [Hash] data the initial data structure to pass through to the transform steps
      # @yield (optionally..) each transformed document after it is transformed but before
      #        it is sent to the loaders
      def call(data: {}, &block)
        extract.with_index do |source, index|
          with_source(source, index) do
            catch :skip do
              load(transform(data), &block)
            end
          rescue StandardError => e
            on_error(e, data)
          end
        end

        after_call
      end

      ##
      # Estimate the number of documents that will be produced by the pipeline
      #
      # @return [Number]
      def estimated_size
        @estimated_size ||= begin
          compile_steps(sources).sum { |source| source.call(context).count }
        end
      end

      ##
      # Tagged logger for benchmarks and data flow logging.
      # NOTE: this is super weird to support Rails 5.2
      # @private
      # @yield Logger
      def with_logger
        logger = (context&.logger || Rails.logger)
        logger.tagged(pipeline.class) do
          logger.tagged("#<#{source.class} id=#{source&.id if source.respond_to?(:id)}>") do
            @logger = logger
            yield logger
          end
        end
      end

      ##
      # @private
      # @param [Hash] data
      # @return [String] a simplified + truncated version of the data hash for debugging
      def transform_data_for_debugging(data, verbose: $VERBOSE, truncate: 100)
        return data.inspect.truncate(truncate) unless data.is_a?(Hash)
        return "id #{context.unique_key(data) || data&.first(5)&.inspect}" unless verbose

        JSON.fast_generate(data).truncate(truncate)
      end

      ##
      # Propagate exceptions up to the context's error handler.
      def on_error(exception, data)
        context.on_error(self, exception, data)
      end

      private

      ##
      # Set the current source
      # @param [Object] source
      # @param [Number] index
      def with_source(source, index)
        @source = source

        benchmark "Indexing item #{source.inspect.truncate(50)} in resource #{context.resource.id} (#{index} / #{estimated_size})" do
          yield.tap { @source = nil }
        end
      end

      ##
      # Extract data from sources. The defined sources receive the provided context
      # and should return an array or other enumerable of sources to pass through
      # the pipeline.
      #
      # @yield [Object]
      def extract(&block)
        return to_enum(:extract) { estimated_size } unless block_given?

        compile_steps(sources).each do |source|
          source.call(context).each do |data|
            block.call(data)
          end
        end
      end

      ##
      # Transform the source to a document.
      #
      # @param [Hash] from the initial seed data used as the input to the initial transforms
      # @return [Hash] the transformed document
      def transform(from)
        compile_steps(pre_processes).each { |step| step.call(from, self) }

        data = compile_steps(transforms).inject(from) { |input, step| step.call(input, self) }

        compile_steps(post_processes).each { |step| step.call(data, self) }

        with_logger do |logger|
          logger.debug do
            "Transform output: #{transform_data_for_debugging(data, verbose: true, truncate: 1000)}"
          end
        end

        data
      end

      ##
      # Load a document into a data sink.
      #
      # @param [Hash] the fully transformed data
      # @yield [Hash] the data before it is sent to any loaders
      def load(data, &block)
        return unless data

        catch :skip do
          block&.call(data, self)

          compile_steps(loaders).each do |loader|
            loader.call(data, self)
          end
        end
      end

      ##
      # A callback run after transforming data to do any finalizing or cleanup
      # from the run.
      def after_call
        finalize_loaders
        @cache = {} unless @provided_cache
        @step_cache = {}
      end

      ##
      # Loaders may implement a `#finalize` method if they want to perform any work
      # after all the data is transformed.
      def finalize_loaders
        compile_steps(loaders).each do |step|
          step.finalize(self) if step.respond_to? :finalize
        end
      end

      ##
      # DSL convenience utility for writing compact lists of steps; this unrolls
      # pipeline definitions to contain arrays or hashes, e.g.:
      # `pipeline.transforms = [step_1: lambda {}, step_2: lambda {}]`
      #
      # @return [Enumerable<Spotlight::Etl::Step>]
      def compile_steps(steps)
        return to_enum(:compile_steps, steps) unless block_given?

        steps.flatten.each do |step|
          if step.is_a? Hash
            step.each do |k, v|
              yield(@step_cache[k] ||= Spotlight::Etl::Step.new(v, label: k, executor: self))
            end
          else
            yield @step_cache[step] ||= Spotlight::Etl::Step.new(step, executor: self)
          end
        end
      end
    end
  end
end
