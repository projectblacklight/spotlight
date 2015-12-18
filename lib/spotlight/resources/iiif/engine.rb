require 'spotlight/engine'

module Spotlight::Resources::Iiif
  class Engine < ::Rails::Engine
    Spotlight::Resources::Iiif::Engine.config.resource_partials = ['spotlight/resources/iiif/manifest']
    Spotlight::Resources::Iiif::Engine.config.metadata_class = -> { Spotlight::Resources::IiifManifest::Metadata }
    Spotlight::Resources::Iiif::Engine.config.iiif_manifest_field = :content_metadata_iiif_manifest_ssm


    initializer 'spotlight.resources.iiif.initialize' do
      Spotlight::Engine.config.resource_providers << Spotlight::Resources::IiifHarvester
      Spotlight::Engine.config.new_resource_partials ||= []
      Spotlight::Engine.config.new_resource_partials << 'spotlight/resources/iiif/tabbed_form'
    end
  end
end
