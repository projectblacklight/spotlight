#Load blacklight which will give spotlight views a higher preference than those in blacklight
require 'blacklight'
require 'blacklight/gallery'
require 'spotlight/rails/routes'

module Spotlight
  class Engine < ::Rails::Engine
    isolate_namespace Spotlight
    initializer "require dependencies" do
      require 'sir-trevor-rails'
      require 'carrierwave'
      require 'carrierwave/orm/activerecord'
      require 'cancan'
      require 'bootstrap_form'
      require 'acts-as-taggable-on'
      require 'rails3-jquery-autocomplete'
    end

    # BlacklightHelper is needed by all helpers, so we inject it
    # into action view base here.
    initializer 'spotlight.helpers', after: :set_autoload_paths do |app|
      ActionView::Base.send :include, Spotlight::MainAppHelpers

      # This fails unless Blacklights generators have already run.
      # (e.g. not during rake engine_cart:generate)
      # Since it's an autoloaded constant, checking defined? ::SolrDocument will
      # always be false.
      begin
        ::SolrDocument.send :include, Spotlight::SolrDocument
      rescue NameError
      end
    end
  end
end
