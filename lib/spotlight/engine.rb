module Spotlight
  class Engine < ::Rails::Engine
    isolate_namespace Spotlight
    require 'sir-trevor-rails'
    require 'carrierwave'
  end
end
