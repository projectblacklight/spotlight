#Load blacklight which will give spotlight views a higher preference than those in blacklight
require 'blacklight'
require 'blacklight/gallery'
require 'spotlight/rails/routes'
require 'spotlight/utils'
require 'friendly_id'
require 'devise'
require 'active_model_serializers'
require 'openseadragon'

module Spotlight
  class Engine < ::Rails::Engine
    isolate_namespace Spotlight
    # Breadcrumbs on rails must be required outside of an initializer or it doesn't get loaded.
    require 'breadcrumbs_on_rails'
    require 'carrierwave'
    require 'social-share-button'

    config.autoload_paths += %W(
      #{config.root}/app/builders
      #{config.root}/app/forms
    )

    initializer "spotlight.initialize" do
      require 'sir-trevor-rails'
      require 'cancan'
      require 'bootstrap_form'
      require 'acts-as-taggable-on'
      require 'oembed'
    end

    initializer "oembed.initialize" do
      OEmbed::Providers.register_all
    end

    Spotlight::Engine.config.resource_providers = []

    Blacklight::Engine.config.inject_blacklight_helpers = false
    Blacklight::Configuration.default_values[:default_autocomplete_solr_params] = {fl: '*', qf: 'id^1000 full_title_tesim^100 id_ng full_title_ng'}
    Blacklight::Configuration.default_values[:index].timestamp_field ||= 'timestamp'

  end
end
