# frozen_string_literal: true

require 'fileutils'
require_relative 'generator_common_utilities'

module Spotlight
  module Assets
    # Spotlight Importmap Generator
    class ImportmapGenerator < Rails::Generators::Base
      include GeneratorCommonUtilities

      source_root Spotlight::Engine.root.join('lib', 'generators', 'spotlight', 'templates')

      class_option :test, type: :boolean, default: false, aliases: '-t', desc: 'Indicates that app will be installed in a test environment'
      class_option :'bootstrap-version', type: :string, default: ENV.fetch('BOOTSTRAP_VERSION', '~> 5.3'), desc: "Set the generated app's bootstrap version"

      desc <<-DESCRIPTION
        This generator configures the Spotlight app to use importmap for
        javascript and bundling for the styles:

        - Adds the frontend style dependencies, including spotlight-frontend,
          via yarn
        - Configures cssbundling-rails to build the styles
        - Javascript from gems such as Blacklight and Spotlight are delivered
          via importmap/the asset pipeline without the need for bundling
      DESCRIPTION

      def add_stylesheet_dependencies
        run "yarn add blacklight-frontend@#{blacklight_yarn_version}"
        run "yarn add bootstrap@\"^#{bootstrap_yarn_version}\""
        run 'yarn add leaflet'
      end

      # Needed for the stylesheets
      def add_frontend
        if ENV['CI']
          run "yarn add file:#{Spotlight::Engine.root}"
        elsif options[:test]
          link_spotlight_frontend

        # If a branch was specified (e.g. you are running a template.rb build
        # against a test branch), use the latest version available on npm
        elsif ENV['BRANCH']
          run 'yarn add spotlight-frontend@latest'

        # Otherwise, pick the version from npm that matches the Spotlight
        # gem version
        else
          run "yarn add spotlight-frontend@#{spotlight_yarn_version}"
        end
      end

      def add_javascript
        # This may have been added from Blacklight, but it is a Spotlight dependency so ensure it is present.
        insert_into_file 'app/javascript/application.js', "import githubAutoCompleteElement from \"@github/auto-complete-element\"\n"

        append_to_file 'app/javascript/application.js' do
          <<~CONTENT

            import Spotlight from "spotlight"

            Blacklight.onLoad(function() {
              Spotlight.activate();
            });
          CONTENT
        end
      end

      def add_stylesheets
        copy_file 'assets/spotlight.scss', 'app/assets/stylesheets/spotlight.scss'
        append_to_file 'app/assets/stylesheets/application.bootstrap.scss' do
          <<~CONTENT
            @import "spotlight";
          CONTENT
        end
      end

      private

      def bootstrap_frontend_version
        yarn_lock = File.read('yarn.lock')
        bootstrap_entry = yarn_lock.match(/^"?bootstrap@.+:\n  version "(.+)"/)
        bootstrap_entry ? bootstrap_entry[1] : nil
      end
    end
  end
end
