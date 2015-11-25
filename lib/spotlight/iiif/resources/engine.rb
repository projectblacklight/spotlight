require 'spotlight/engine'

module Spotlight::Iiif::Resources
  class Engine < ::Rails::Engine
    Spotlight::Iiif::Resources::Engine.config.resource_partials = ['spotlight/resources/iiif/manifest']
    initializer 'spotlight.iiif.initialize' do
      Spotlight::Engine.config.resource_providers << Spotlight::Resources::IiifHarvester
      Spotlight::Engine.config.new_resource_partials ||= []
      Spotlight::Engine.config.new_resource_partials << 'spotlight/resources/iiif/tabbed_form'
    end
  end
end