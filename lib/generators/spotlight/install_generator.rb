require 'rails/generators'

module Spotlight
  class Install < Rails::Generators::Base
    def inject_spotlight_routes
      route "mount Spotlight::Engine, at: 'spotlight'"
    end
  end
end