require 'rails/generators'

module Spotlight
  ##
  # spotlight:tamu generator
  class Tamu < Rails::Generators::Base
    source_root File.expand_path('../tamu', __FILE__)

    def tamu_customizations
      directory 'app', 'app'
      directory 'config', 'config'
    end

    def add_example_catalog_controller
      copy_file 'catalog_controller.rb', 'app/controllers/catalog_controller.rb'
    end

    def tamu_assets_precompile
      append_to_file 'config/initializers/assets.rb', 'Rails.application.config.assets.precompile += %w( *.svg *.png *.ico )'
    end

    def tinymce_rails
      gem 'tinymce-rails'
    end
  end
end
