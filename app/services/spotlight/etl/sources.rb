# frozen_string_literal: true

module Spotlight
  module Etl
    # Basic ETL source implementations
    module Sources
      # A simple source that just returns the original resource(s)
      IdentitySource = lambda do |context|
        Array.wrap(context.resource)
      end

      # A transform step that calls a method on the resource to generate a source
      def self.SourceMethodSource(method) # rubocop:disable Naming/MethodName
        lambda do |context|
          context.resource.public_send(method)
        end
      end

      # A simple source that retrieves the stored data from a Spotlight::Resource
      StoredData = lambda do |context, **|
        Array.wrap(context.resource.data)
      end
    end
  end
end
