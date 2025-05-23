# frozen_string_literal: true

module Spotlight
  # Run general asset setup and then delegate to the appropriate generator
  # Based on Blacklight::AssetsGenerator
  class AssetsGenerator < Rails::Generators::Base
    class_option :test, type: :boolean, default: ENV.fetch('CI', false) == 'true', aliases: '-t',
                        desc: 'Indicates that app will be installed in a test environment'
    class_option :'bootstrap-version', type: :string, default: ENV.fetch('BOOTSTRAP_VERSION', '~> 5.3'), desc: "Set the generated app's bootstrap version"

    def run_asset_pipeline_specific_generator
      generated_options = '--test=true' if options[:test]
      generator = if defined?(Importmap)
                    'spotlight:assets:importmap'
                  elsif defined?(Propshaft)
                    'spotlight:assets:propshaft'
                  end

      generate generator, generated_options
    end
  end
end
