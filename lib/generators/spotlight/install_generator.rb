# frozen_string_literal: true

require 'rails/generators'

module Spotlight
  ##
  # spotlight:install generator
  class Install < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)
    class_option :solr_update_class, type: :string, default: 'Spotlight::SolrDocument::AtomicUpdates'
    class_option :mailer_default_url_host, type: :string, default: '' # e.g. localhost:3000

    def add_manifest
      append_to_file 'app/assets/javascripts/application.js', "\n//= require_tree .\n"
      append_to_file 'app/assets/config/manifest.js', "\n//= link spotlight/manifest.js"

      # Rails installed importmap by default, but we don't have importmap + Blacklight 7 working yet.
      remove_file 'app/javascript/application.js'
    end

    def inject_spotlight_routes
      route "mount Spotlight::Engine, at: 'spotlight'"
      gsub_file 'config/routes.rb', /^\s*root.*/ do |match|
        '#  ' + match.strip + ' # replaced by spotlight root path'
      end
      route "root to: 'spotlight/exhibits#index'"
    end

    def friendly_id
      gem 'friendly_id'
      bundle_install
      generate 'friendly_id'
    end

    def riiif
      gem 'riiif'
      Bundler.with_unbundled_env { run 'bundle install' }
      route "mount Riiif::Engine => '/images', as: 'riiif'"
      copy_file 'config/initializers/riiif.rb'
    end

    def paper_trail
      generate 'paper_trail:install'
    end

    def sitemaps
      gem 'sitemap_generator'

      bundle_install

      copy_file 'config/sitemap.rb', 'config/sitemap.rb'

      say <<~EOS, :red
        Added a default sitemap_generator configuration in config/sitemap.rb; please
        update the default host to match your environment
      EOS
    end

    def assets
      copy_file 'spotlight.scss', 'app/assets/stylesheets/spotlight.scss'
      copy_file 'spotlight.js', 'app/assets/javascripts/spotlight.js'
    end

    def add_roles_to_user
      inject_into_file 'app/models/user.rb', after: 'include Blacklight::User' do
        "\n  include Spotlight::User\n"
      end
    end

    def add_controller_mixin
      inject_into_file 'app/controllers/application_controller.rb', after: 'include Blacklight::Controller' do
        "\n  include Spotlight::Controller\n"
      end
    end

    def add_helper
      copy_file 'spotlight_helper.rb', 'app/helpers/spotlight_helper.rb'
      inject_into_file 'app/helpers/application_helper.rb', after: 'module ApplicationHelper' do
        "\n  include SpotlightHelper"
      end
    end

    def add_model_mixin
      if File.exist? File.expand_path('app/models/solr_document.rb', destination_root)
        inject_into_file 'app/models/solr_document.rb', after: 'include Blacklight::Solr::Document' do
          "\n  include Spotlight::SolrDocument\n"
        end
      else
        say 'Unable to find SolrDocument class; add `include Spotlight::SolrDocument` to the class manually'
      end
    end

    def add_solr_indexing_mixin
      if File.exist? File.expand_path('app/models/solr_document.rb', destination_root)
        inject_into_file 'app/models/solr_document.rb', after: "include Spotlight::SolrDocument\n" do
          "\n  include #{options[:solr_update_class]}\n"
        end
      else
        say "Unable to find SolrDocument class; add `include #{options[:solr_update_class]}` to the class manually"
      end
    end

    def add_search_builder_mixin
      if File.exist? File.expand_path('app/models/search_builder.rb', destination_root)
        inject_into_file 'app/models/search_builder.rb', after: "include Blacklight::Solr::SearchBuilderBehavior\n" do
          "\n  include Spotlight::SearchBuilder\n"
        end
      else
        say 'Unable to find SearchBuilder class; add `include Spotlight::SearchBuilder` to the class manually.'
      end
    end

    def add_example_catalog_controller
      copy_file 'catalog_controller.rb', 'app/controllers/catalog_controller.rb'
    end

    def add_osd_viewer
      unless Bundler.locked_gems.dependencies.key? 'blacklight-gallery'
        gem 'blacklight-gallery', '~> 4.0'
        bundle_install
      end
      generate 'blacklight_gallery:install'
    end

    def configure_osd_for_sprockets
      return unless defined?(Sprockets)

      append_to_file 'app/assets/javascripts/application.js', "\n//= require openseadragon\n//= require openseadragon-rails/openseadragon-rails\n"

      append_to_file 'config/initializers/assets.rb' do
        <<~CONTENT
          Rails.application.config.assets.paths << Rails.root.join('node_modules/openseadragon/build/openseadragon')
          Rails.application.config.assets.paths << Rails.root.join('node_modules/openseadragon/build/openseadragon/images')
        CONTENT
      end

      append_to_file 'app/assets/config/manifest.js', "//= link_tree ../../../node_modules/openseadragon/build/openseadragon/images\n"

      inject_into_file 'app/controllers/application_controller.rb', after: 'class ApplicationController < ActionController::Base' do
        "\n  helper Openseadragon::OpenseadragonHelper\n"
      end
    end

    def add_oembed
      unless Bundler.locked_gems.dependencies.key? 'blacklight-oembed'
        gem 'blacklight-oembed', '~> 1.0'
        bundle_install
      end
      generate 'blacklight_oembed:install'
      copy_file 'config/initializers/oembed.rb'

      return unless defined?(Sprockets)

      # Use the rolled up assets from blacklight-oembed for sprockets
      gsub_file 'app/assets/javascripts/blacklight_oembed.js', "import oembed from 'blacklight_oembed/oembed'",
                '//= require blacklight_oembed/oembed'
    end

    def add_mailer_defaults
      if options[:mailer_default_url_host].present?
        say 'Injecting a placeholder config.action_mailer.default_url_options; be sure to update it for your environment', :yellow
        insert_into_file 'config/application.rb', after: "< Rails::Application\n" do
          <<-EOF
          config.action_mailer.default_url_options = { host: "#{options[:mailer_default_url_host]}", from: "noreply@example.com" }
          EOF
        end
      else
        say 'Please add a default configuration config.action_mailer.default_url_options for your environment', :red
      end
    end

    def generate_devise_invitable
      gem 'devise_invitable'
      bundle_install
      generate 'devise_invitable:install'
      generate 'devise_invitable', 'User'
    end

    def generate_config
      directory 'config'
    end

    def add_solr_config_resources
      copy_file '.solr_wrapper.yml', '.solr_wrapper.yml'
      directory 'solr'
    end

    def configure_logging
      insert_into_file 'config/application.rb', after: "< Rails::Application\n" do
        <<-EOF
        # Logging
        if ENV["RAILS_LOG_TO_STDOUT"].present?
          config.log_level = :debug
          config.log_formatter = ::Logger::Formatter.new
          # log to stdout
          logger               = ActiveSupport::Logger.new(STDOUT)
          logger.formatter     = config.log_formatter
          config.logger        = ActiveSupport::TaggedLogging.new(logger)
          # Print deprecation notices to the Rails logger.
          config.active_support.deprecation = :log
          # Raise an error on page load if there are pending migrations.
          config.active_record.migration_error = :page_load
          # Highlight code that triggered database queries in logs.
          config.active_record.verbose_query_logs = true
        end
        EOF
      end
    end

    private

    def bundle_install
      inside destination_root do
        Bundler.with_unbundled_env { run 'bundle install' }
      end
    end
  end
end
