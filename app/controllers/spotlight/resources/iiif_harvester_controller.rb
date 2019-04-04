# frozen_string_literal: true

module Spotlight
  module Resources
    # IIIF resources harvesting endpoint
    class IiifHarvesterController < Spotlight::ResourcesController
      def resource_class
        Spotlight::Resources::IiifHarvester
      end
    end
  end
end
