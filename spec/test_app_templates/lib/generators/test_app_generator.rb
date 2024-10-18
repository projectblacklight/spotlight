# frozen_string_literal: true

require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root '../spec/test_app_templates'

  def use_capybara3
    gsub_file 'Gemfile', /gem 'capybara'/, '# gem \'capybara\''
  end

  def add_gems
    gem 'blacklight', ENV['BLACKLIGHT_VERSION'] || '~> 7.38' unless Bundler.locked_gems.dependencies.key? 'blacklight'
    gem 'blacklight-gallery', '~> 4.5' unless Bundler.locked_gems.dependencies.key? 'blacklight-gallery'

    unless Bundler.locked_gems.dependencies.key? 'bootstrap_form'
      bootstrap_version = ENV.fetch('BOOTSTRAP_VERSION', '~> 5.3')
      gem 'bootstrap_form', /(\d)(?:\.\d){0,2}/.match(bootstrap_version)[1].to_i == 5 ? '~> 5.4' : '~> 4.5'
    end

    Bundler.with_unbundled_env do
      run 'bundle install'
    end
  end

  def run_blacklight_generator
    say_status('warning', 'GENERATING BL', :yellow)

    generate :'blacklight:install', '--devise'
  end

  def run_spotlight_migrations
    rake 'spotlight:install:migrations'
    rake 'db:migrate'
  end

  def add_spotlight_routes_and_assets
    generate :'spotlight:install', '-f --mailer_default_url_host=localhost:3000 --test'
    append_to_file 'app/assets/config/manifest.js', "\n//= link application.js\n" if File.exist?('app/assets/config/manifest.js')
  end

  def install_test_catalog_controller
    copy_file 'catalog_controller.rb', 'app/controllers/catalog_controller.rb', force: true
  end

  def add_rake_tasks_to_app
    rakefile 'spotlight_test.rake', File.read(find_in_source_paths('spotlight_test.rake'))
  end

  def disable_carrierwave_processing
    copy_file 'carrierwave.rb', 'config/initializers/carrierwave.rb'
  end

  def add_theme_assets
    copy_file 'fixture.png', 'app/assets/images/spotlight/themes/default_preview.png'
    copy_file 'fixture.png', 'app/assets/images/spotlight/themes/modern_preview.png'

    copy_file 'fixture.css', 'app/assets/stylesheets/application_modern.css'
    append_to_file 'config/initializers/assets.rb', 'Rails.application.config.assets.precompile += %w( application_modern.css )'

    append_to_file 'config/initializers/spotlight_initializer.rb', "\nSpotlight::Engine.config.exhibit_themes = %w[default modern]"
  end

  def disable_filter_resources_by_exhibit
    initializer 'disable_filter_resources_by_exhibit.rb' do
      <<-EOF
      # Setting this to false when running tests so that we don't have to set up
      # exhibit specific solr documents for tests that don't use the default exhibit.
      Spotlight::Engine.config.filter_resources_by_exhibit = false
      EOF
    end
  end

  def raise_on_missing_translation
    uncomment_lines 'config/environments/development.rb', /config.action_view.raise_on_missing_translations/
    uncomment_lines 'config/environments/test.rb', /config.action_view.raise_on_missing_translations/
  end
end
