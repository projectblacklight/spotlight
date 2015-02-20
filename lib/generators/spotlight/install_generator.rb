require 'rails/generators'

module Spotlight
  class Install < Rails::Generators::Base

    source_root File.expand_path('../templates', __FILE__)
    class_option :solr_update_class, type: :string , default: "Spotlight::SolrDocument::AtomicUpdates"
    class_option :mailer_default_url_host, type: :string, default: '' # e.g. localhost:3000

    def inject_spotlight_routes
      route "mount Spotlight::Engine, at: 'spotlight'"
      gsub_file 'config/routes.rb', /^\s*root.*/ do |match|
        "#" + match + " # replaced by spotlight_root"
      end

      route "spotlight_root"
    end

    def friendly_id
      gem "friendly_id"
      generate "friendly_id"
    end

    def assets
      copy_file "spotlight.scss", "app/assets/stylesheets/spotlight.scss"
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
      if File.exists? 'app/models/solr_document.rb'
        inject_into_file 'app/models/solr_document.rb', after: "include Blacklight::Solr::Document" do
         "\n  include Spotlight::SolrDocument\n"
        end
      else
        say "Unable to find SolrDocument class; add `include Spotlight::SolrDocument` to the class manually"
      end
    end

    def add_solr_indexing_mixin
      if File.exists? 'app/models/solr_document.rb'
        inject_into_file 'app/models/solr_document.rb', after: "include Spotlight::SolrDocument\n" do
         "\n  include #{options[:solr_update_class]}\n"
        end
      else
        say "Unable to find SolrDocument class; add `include #{options[:solr_update_class]}` to the class manually"
      end
    end

    def add_osd_viewer
      gem 'blacklight-gallery'
      generate 'blacklight_gallery:install'
    end

    def add_oembed
      gem 'blacklight-oembed'
      generate 'blacklight_oembed:install'
    end

    def add_mailer_defaults
      if options[:mailer_default_url_host].present?
        say "Injecting a placeholder config.action_mailer.default_url_options; be sure to update it for your environment", :yellow
        insert_into_file 'config/application.rb', after: "< Rails::Application\n" do <<-EOF
          config.action_mailer.default_url_options = { host: "#{options[:mailer_default_url_host]}", from: "noreply@example.com" }
        EOF
        end
      else
        say "Please add a default configuration config.action_mailer.default_url_options for your environment", :red
      end
    end

    def generate_social_share_button_initializer
      gem 'social-share-button'
      directory 'config'
    end
  end
end
