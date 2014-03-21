require 'rails/generators'

module Spotlight
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)

    def inject_spotlight_routes
      route "mount Spotlight::Engine, at: 'spotlight'"
      gsub_file 'config/routes.rb', /^\s*root.*/ do |match|
        "#" + match + " # replaced by spotlight_root"
      end

      route "spotlight_root"
    end

    def friendly_id
      generate "friendly_id"
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

    def add_helper
      copy_file "spotlight_helper.rb", "app/helpers/spotlight_helper.rb"
      inject_into_class 'app/helpers/application_helper.rb', ApplicationHelper, "  include SpotlightHelper"
    end

    def add_model_mixin
      inject_into_file 'app/models/solr_document.rb', after: "include Blacklight::Solr::Document" do
       "\n  include Spotlight::SolrDocument\n" +
       "include Spotlight::SolrDocument::AtomicUpdates\n" +
       "include Spotlight::SolrDocument::Openseadragon\n"
     end
    end

    def generate_social_share_button_initializer
      directory 'config'
    end
  end
end
