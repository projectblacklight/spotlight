#Load blacklight which will give spotlight views a higher preference than those in blacklight
require 'blacklight'
require 'blacklight/gallery'
require 'spotlight/rails/routes'

module Spotlight
  class Engine < ::Rails::Engine
    isolate_namespace Spotlight
    # Breadcrumbs on rails must be required outside of an initializer or it doesn't get loaded.
    require 'breadcrumbs_on_rails'
    require 'carrierwave'

    config.autoload_paths += %W(
      #{config.root}/app/builders
    )

    initializer "spotlight.initialize" do
      require 'sir-trevor-rails'
      require 'cancan'
      require 'bootstrap_form'
      require 'acts-as-taggable-on'
    end


    Blacklight::Engine.config.inject_blacklight_helpers = false

  end
end
