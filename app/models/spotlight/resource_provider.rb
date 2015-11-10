module Spotlight
  ##
  # Detect which Spotlight::Resource subclasses can provide indexing routines for
  # a given resource
  class ResourceProvider
    class <<self
      ##
      # @return [Class] the class that can best provide indexing for the resource
      def for_resource(resource)
        providers_for_resource(resource).first
      end

      private

      def providers
        Spotlight::Engine.config.resource_providers
      end

      def providers_for_resource(resource)
        providers.select { |provider| provider.can_provide? resource }.sort_by(&:weight)
      end
    end
  end
end
