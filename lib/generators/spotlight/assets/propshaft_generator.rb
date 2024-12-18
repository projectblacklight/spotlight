# frozen_string_literal: true

require 'fileutils'
require_relative 'generator_common_utilities'

module Spotlight
  module Assets
    # Spotlight Propshaft Generator
    class PropshaftGenerator < Rails::Generators::Base
      include GeneratorCommonUtilities

      source_root Spotlight::Engine.root.join('lib', 'generators', 'spotlight', 'templates')

      class_option :test, type: :boolean, default: false, aliases: '-t', desc: 'Indicates that app will be installed in a test environment'
      class_option :'bootstrap-version', type: :string, default: ENV.fetch('BOOTSTRAP_VERSION', '~> 5.3'), desc: "Set the generated app's bootstrap version"

      desc <<-DESCRIPTION
        This generator configures the Spotlight app to use bundling for both
        javascript and styles:

        - Adds frontend dependencies, including spotlight-frontend, via yarn
        - Configures jsbundling-rails (w/ esbuild) to bundle the JS
        - Configures cssbundling-rails to build the styles
      DESCRIPTION

      def install_dependencies
        run 'yarn add @github/auto-complete-element'
        run 'yarn add @hotwired/turbo-rails'
        run 'yarn add clipboard'
        run 'yarn add leaflet'
        run 'yarn add sir-trevor'
        run 'yarn add sortablejs'
      end

      def add_blacklight_frontend
        run "yarn add blacklight-frontend@#{blacklight_yarn_version}"
      end

      def add_bootstrap
        run "yarn add bootstrap@\"^#{bootstrap_yarn_version}\""
        run 'yarn add @popperjs/core'
      end

      # Pick a version of the frontend asset package and install it.
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
        copy_file 'javascript/jquery-shim.js', 'app/javascript/jquery-shim.js'
        gsub_file 'app/javascript/application.js', 'import "controllers"', '// import "controllers"'

        # This may have been added from Blacklight, but it is a Spotlight dependency so ensure it is present.
        insert_into_file 'app/javascript/application.js', "import githubAutoCompleteElement from \"@github/auto-complete-element\";\n"

        append_to_file 'app/javascript/application.js' do
          <<~CONTENT
            import Spotlight from "spotlight-frontend"

            Blacklight.onLoad(function() {
              Spotlight.activate();
            });
          CONTENT
        end
      end

      def add_stylesheets
        copy_file 'assets/spotlight.scss', 'app/assets/stylesheets/spotlight.scss'
        append_to_file 'app/assets/stylesheets/application.bootstrap.scss', "\n@import \"spotlight\";\n"
      end

      def configure_esbuild
        # The main-fields option resolves a bundling issue with bootstrap/popper on esbuild.
        custom_options = '--main-fields=main,module --alias:jquery=./app/javascript/jquery-shim.js'
        custom_options = "#{custom_options} --preserve-symlinks" if options[:test]
        gsub_file 'package.json',
                  'esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets',
                  "esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets #{custom_options}"
      end
    end
  end
end
