# frozen_string_literal: true

require 'fileutils'

module Spotlight
  module Assets
    # Spotlight Propshaft Generator
    class PropshaftGenerator < Rails::Generators::Base
      source_root Spotlight::Engine.root.join('lib', 'generators', 'spotlight', 'templates')

      class_option :test, type: :boolean, default: false, aliases: '-t', desc: 'Indicates that app will be installed in a test environment'
      class_option :'bootstrap-version', type: :string, default: ENV.fetch('BOOTSTRAP_VERSION', '~> 5.3'), desc: "Set the generated app's bootstrap version"

      desc <<-DESCRIPTION
      The Spotlight frontend assets are installed from the npm package. In
      local development they automatically reference the versions from the
      outer directory (the Spotlight repository) via a yarn symlink.
      DESCRIPTION

      def install_dependencies
        copy_file 'package.json', 'package.json' unless File.exist?('package.json')
        run 'yarn add @hotwired/turbo-rails'
        run 'yarn add clipboard'
        run 'yarn add jquery'
        run 'yarn add jquery-serializejson'
        run 'yarn add leaflet'
        run 'yarn add leaflet-iiif'
        run 'yarn add sir-trevor'
        run 'yarn install'
      end

      def add_blacklight_frontend
        run "yarn add blacklight-frontend@#{Blacklight::VERSION}"
      end

      def add_bootstrap
        run "yarn add bootstrap@\"~#{bootstrap_yarn_version}\""
        if bootstrap4?
          run 'yarn add popper.js'
        else
          run 'yarn add @popperjs/core'
        end
      end

      def install_gems
        gem 'jsbundling-rails'
        gem 'cssbundling-rails'
      end

      def bundle_install
        inside destination_root do
          Bundler.with_unbundled_env do
            run 'bundle install'
          end
        end
      end

      def install_javascript_bundler
        rails_command 'javascript:install:esbuild'
      end

      def install_sass_bundler
        rails_command 'css:install:sass'
      end

      # Pick a version of the frontend asset package and install it.
      def add_frontend
        if options[:test]
          link_spotlight_frontend

        # If a branch was specified (e.g. you are running a template.rb build
        # against a test branch), use the latest version available on npm
        elsif ENV['BRANCH']
          run 'yarn add spotlight-frontend@latest'

        # Otherwise, pick the version from npm that matches the Spotlight
        # gem version
        else
          run "yarn add spotlight-frontend@#{Spotlight::VERSION}"
        end
      end

      def add_javascript
        gsub_file 'app/javascript/application.js', 'import "controllers"', '// import "controllers"'

        append_to_file 'app/javascript/application.js', "\n// Bootstrap\nimport * as Bootstrap from 'bootstrap'\n"

        if Blacklight::VERSION.start_with?('7')
          append_to_file 'app/javascript/application.js', "\n// Blacklight\nimport \"blacklight-frontend/app/assets/javascripts/blacklight/blacklight.js\"\n"
        end

        append_to_file 'app/javascript/application.js', "\n// Spotlight\nimport Spotlight from \"spotlight-frontend\"\n"
      end

      def add_stylesheets
        copy_file 'assets/spotlight.scss', 'app/assets/stylesheets/spotlight.scss'
        append_to_file 'app/assets/stylesheets/application.sass.scss', "\n@import \"spotlight\";\n"
      end

      # This resolves a bundling issue with bootstrap/popper on esbuild.
      def configure_esbuild
        gsub_file 'package.json',
                  'esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets',
                  'esbuild app/javascript/*.* --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets --main-fields=main,module'
      end

      private

      # Support the gem version format e.g.,  `~> 5.3` for consistency.
      def bootstrap_yarn_version
        options[:'bootstrap-version'].match(/(\d+(\.\d+)*)/)[0]
      end

      def bootstrap4?
        bootstrap_yarn_version.start_with?('4')
      end

      # Yarn link was including so many files (and a circular reference) that Propshaft was having a bad time.
      def link_spotlight_frontend
        empty_directory 'node_modules/spotlight-frontend'
        empty_directory 'node_modules/spotlight-frontend/app'
        File.symlink Spotlight::Engine.root.join('package.json'), 'node_modules/spotlight-frontend/package.json'
        File.symlink Spotlight::Engine.root.join('vendor'), 'node_modules/spotlight-frontend/vendor'
        File.symlink Spotlight::Engine.root.join('app/assets'), 'node_modules/spotlight-frontend/app/assets'
      end
    end
  end
end
