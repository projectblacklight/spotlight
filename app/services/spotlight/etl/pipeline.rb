# frozen_string_literal: true

module Spotlight
  module Etl
    # ETL pipeline definition
    class Pipeline
      include ActiveSupport::Benchmarkable

      attr_reader :context, :source

      # This ETL pipeline system, while somewhat generic, was implemented for Spotlight
      # to transform Spotlight::Resource instances into Solr documents. The resources
      # go through a series of steps (sources, transforms, loaders) to produce one or
      # more documents in the Solr index.
      #
      # All of the steps below can be provided as:
      #  - a lambda
      #  - a ruby class (which will be initialized for each pipeline execution)
      #  - or, a hash (of any length) with:
      #       - a key (used only for clarity in logging, particularly useful to label lambdas)
      #       - a value that is one of the valid step types (lambda or ruby class).
      #
      # Any of the transform or loader steps can `throw :skip` to skip the current source.
      #
      # Any exceptions raised by the pipeline's steps are sent to the context's
      # error handler by calling `#on_error` on the context object.

      # sources return enumerables that convert from the Spotlight::Etl::Context
      # to some data structure that the transform steps can handle. The Context is provided
      # by the implementation when the pipeline is executed.
      class_attribute :sources, default: []

      # The transform steps (pre-processes, transforms, and post-processes) receive
      # the current data state and the pipeline. The return value from the transforms
      # steps replaces the current data state, however the return values for pre- and
      # post- processing is ignored (although they may mutate the provided data, pipeline, etc).
      #
      # Through the pipeline argument, the transform steps can access:
      #  - `context`, the implementation-provided resource
      #  - `source`, the current source instance
      class_attribute :pre_processes, default: []
      class_attribute :transforms, default: []
      class_attribute :post_processes, default: []

      # loaders receive the transformed data and.. do something with it (like load it into Solr)
      # After all documents are transformed, the loader may also receive `#finalize` to finish any
      # additional processing.
      class_attribute :loaders, default: []

      def initialize
        yield(self) if block_given?
      end

      ##
      # Execute the ETL pipeline
      #
      # @param [Spotlight::Etl::Context] context
      # @param [Hash] data the initial data structure to pass through to the transform steps
      # @yield (optioanlly..) each transformed document after it is transformed but before
      #        it is sent to the loaders
      def call(context, data: {}, cache: nil, &block)
        executor(context, cache:).call(data:, &block)
      end

      ##
      # Estimate the number of documents that will be produced by the pipeline
      #
      # @param [Spotlight::Etl::Context] context
      # @return [Number]
      def estimated_size(context)
        executor(context).estimated_size
      end

      private

      def executor(context, **args)
        Spotlight::Etl::Executor.new(self, context, **args)
      end
    end
  end
end
