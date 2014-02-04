require 'rails/generators'

module Spotlight
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def inject_spotlight_routes
      route "mount Spotlight::Engine, at: 'spotlight'"
    end

    def assets
      copy_file "spotlight.css.scss", "app/assets/stylesheets/spotlight.css.scss"
      copy_file "spotlight.js", "app/assets/javascripts/spotlight.js"
    end

    def add_roles_to_user
      inject_into_class 'app/models/user.rb', User, "  include Spotlight::User"
    end

    def add_controller_mixin
      inject_into_file 'app/controllers/application_controller.rb', after: "include Blacklight::Controller" do
        "\n  include Spotlight::Controller\n"
      end
    end

    def add_catalog_mixin
      inject_into_file 'app/controllers/catalog_controller.rb', after: "include Blacklight::Catalog" do
        "\n  include Spotlight::Catalog\n"
      end
    end
  end
end
