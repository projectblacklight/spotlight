require 'spotlight/engine'

module Spotlight::Resources::Iiif
  class Engine < ::Rails::Engine
    Spotlight::Resources::Iiif::Engine.config.resource_partial = 'spotlight/resources/iiif/form'
    Spotlight::Resources::Iiif::Engine.config.metadata_class = -> { Spotlight::Resources::IiifManifest::Metadata }
    Spotlight::Resources::Iiif::Engine.config.iiif_manifest_field = :content_metadata_iiif_manifest_ssm


    initializer 'spotlight.resources.iiif.initialize' do
      Spotlight::Engine.config.external_resources_partials ||= []
      Spotlight::Engine.config.external_resources_partials << Spotlight::Resources::Iiif::Engine.config.resource_partial
    end
  end
end
