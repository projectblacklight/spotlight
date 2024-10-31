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
        This generator sets up the app to use importmap to manage the javascript,
        and cssbundling-rails to manage the styles.

        SCSS stylesheets are installed via yarn and built into a single CSS
        stylesheet.

        JS sources from the Blacklight and Spotlight gems are delivered via
        importmap, and their dependencies are pinned to versions delivered via
        CDN.
      DESCRIPTION

      def add_stylesheet_dependencies
        run "yarn add blacklight-frontend@#{blacklight_yarn_version}"
        run "yarn add bootstrap@\"^#{bootstrap_yarn_version}\""
        run 'yarn add leaflet'
      end

      # Until https://github.com/projectblacklight/blacklight/pull/3340 is released for BL8 that changes the order of the asset generators,
      # we need to replicate some of the behavior of Blacklight::Assets::ImportmapGenerator here, because likely the PropshaftGenerator ran.
      def import_blacklight_javascript_assets
        pins = {
          '@github/auto-complete-element' => 'https://cdn.skypack.dev/@github/auto-complete-element',
          '@popperjs/core' => 'https://ga.jspm.io/npm:@popperjs/core@2.11.6/dist/umd/popper.min.js',
          'bootstrap' => "https://ga.jspm.io/npm:bootstrap@#{(defined?(Bootstrap) && Bootstrap::VERSION) || bootstrap_frontend_version}/dist/js/bootstrap.js"
        }

        existing_pins = File.readlines('config/importmap.rb')
        pins.each do |name, url|
          pin_line = "pin \"#{name}\", to: \"#{url}\""
          append_to_file 'config/importmap.rb', "#{pin_line}\n" unless existing_pins.any? { |line| line.include?(name) }
        end
      end

      def install_sass_bundler
        rails_command 'css:install:sass'
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

      # Until https://github.com/projectblacklight/blacklight/pull/3340 is released for BL8 that changes the order of the asset generators,
      # we need to replicate some of the behavior of Blacklight::Assets::ImportmapGenerator here, because likely the PropshaftGenerator ran.
      def add_blacklight_javascript
        application_js = File.read('app/javascript/application.js')

        imports = [
          'import bootstrap from "bootstrap"',
          'import githubAutoCompleteElement from "@github/auto-complete-element"',
          'import Blacklight from "blacklight"'
        ]

        imports.each do |import_line|
          append_to_file 'app/javascript/application.js', "#{import_line}\n" unless application_js.include?(import_line)
        end
      end

      def add_javascript
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
        append_to_file 'app/assets/stylesheets/application.sass.scss' do
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
