module Spotlight
  module Resources
    class IiifHarvesterController < Spotlight::ResourcesController
      def resource_class
        Spotlight::Resources::IiifHarvester
      end
    end
  end
end
