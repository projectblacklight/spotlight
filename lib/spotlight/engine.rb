#Load blacklight which will give spotlight views a higher preference than those in blacklight
require 'blacklight'
require 'blacklight/gallery'

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
  end
end
