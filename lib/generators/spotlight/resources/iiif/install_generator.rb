require 'rails/generators'

module Spotlight
  module Resources
    module Iiif
      class InstallGenerator < Rails::Generators::Base
        desc 'This generator mounts the Spotlight::Resources::Iiif engine'

        def inject_spotlight_iiif_routes
          route "mount Spotlight::Resources::Iiif::Engine, at: 'spotlight_resources_iiif'"
        end
      end
    end
  end
end
