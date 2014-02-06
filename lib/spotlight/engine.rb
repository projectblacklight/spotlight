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
    end

    # BlacklightHelper is needed by all helpers, so we inject it
    # into action view base here.
    initializer 'spotlight.helpers' do |app|
      ActionView::Base.send :include, Spotlight::MainAppHelpers
    end
  end
end
