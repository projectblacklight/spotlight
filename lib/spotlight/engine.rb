module Spotlight
  class Engine < ::Rails::Engine
    isolate_namespace Spotlight
    initializer "require dependencies" do
      require 'sir-trevor-rails'
      require 'carrierwave'
      require 'cancan'
      require 'bootstrap_form'
    end
  end
end
