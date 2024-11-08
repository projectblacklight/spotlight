# frozen_string_literal: true

module Spotlight
  module Assets
    # Utilities for the Spotlight assets generators
    module GeneratorCommonUtilities
      # Some versions of the blacklight/spotlight gem do not have a corresponding package on npm.
      # Assume we want the most recent version that is compatible with the major version of the gem.
      def package_yarn_version(package_name, requested_version)
        versions = JSON.parse(`yarn info #{package_name} versions --json`)['data']
        exact_match = versions.find { |v| v == requested_version }
        return exact_match if exact_match

        major_version = Gem::Version.new(requested_version).segments.first
        "^#{major_version}"
      end

      def blacklight_yarn_version
        package_yarn_version('blacklight-frontend', Blacklight::VERSION)
      end

      def spotlight_yarn_version
        package_yarn_version('spotlight-frontend', Spotlight::VERSION)
      end

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
