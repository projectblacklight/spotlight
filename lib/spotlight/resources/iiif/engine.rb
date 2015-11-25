require 'spotlight/engine'

module Spotlight::Resources::Iiif
  class Engine < ::Rails::Engine
    Spotlight::Resources::Iiif::Engine.config.resource_partials = ['spotlight/resources/iiif/manifest']
    initializer 'spotlight.resources.iiif.initialize' do
      Spotlight::Engine.config.resource_providers << Spotlight::Resources::IiifHarvester
      Spotlight::Engine.config.new_resource_partials ||= []
      Spotlight::Engine.config.new_resource_partials << 'spotlight/resources/iiif/tabbed_form'
    end
  end
end