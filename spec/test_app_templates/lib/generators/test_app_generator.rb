# frozen_string_literal: true

require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root '../spec/test_app_templates'

  def create_package_json
    return if File.exist?('package.json')

    run 'yarn init -y'
    # Fixes: error package.json: Name can't start with a dot
    gsub_file 'package.json', '.internal_test_app', 'internal_test_app'
  end

  # This makes the assets available in the test app so that changes made in
  # local development can be picked up automatically
  def link_frontend
    # This generator is run from inside the test app; we have to get back up
    # to spotlight root to link the right project
    inside('..') do
      run 'yarn link'
    end
  end

  def use_capybara3
    gsub_file 'Gemfile', /gem 'capybara'/, '# gem \'capybara\''
  end

  def add_gems
    gem 'blacklight', ENV['BLACKLIGHT_VERSION'] || '~> 8.0' unless Bundler.locked_gems.dependencies.key? 'blacklight'
    gem 'blacklight-gallery', '~> 4.5' unless Bundler.locked_gems.dependencies.key? 'blacklight-gallery'
    gem 'bootstrap_form' unless Bundler.locked_gems.dependencies.key? 'bootstrap_form'

    Bundler.with_unbundled_env do
      run 'bundle install'
    end
  end

  def run_blacklight_generator
    say_status('warning', 'GENERATING BL', :yellow)

    generate :'blacklight:install', '--devise'
  end

  def add_solid_queue_for_rails7
    return unless Rails.version < '8'

    gem 'solid_queue'
    bundle_install
    generate 'solid_queue:install'
  end

  def configure_solid_queue_database # rubocop:disable Metrics/MethodLength
    gsub_file 'config/database.yml', /^development:\n  <<: \*default\n  database: .*\n/ do
      <<~YAML
        development:
          primary:
            <<: *default
            database: storage/development.sqlite3
          queue:
            <<: *default
            database: storage/development_queue.sqlite3
            migrations_paths: db/queue_migrate
      YAML
    end

    inject_into_file 'config/database.yml', after: /^development:\n  primary:\n    <<: \*default\n    database: .*\n/ do
      <<-YAML

  queue:
    <<: *default
    database: storage/development_queue.sqlite3
    migrations_paths: db/queue_migrate
      YAML
    end
  end

  def use_solid_queue_in_development
    inject_into_file 'config/environments/development.rb', before: /^end/ do
      <<-RUBY

  # Use Solid Queue in Development
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
      RUBY
    end
  end

  def use_solid_queue_puma_plugin_in_development
    return unless File.exist? File.expand_path('config/puma.rb')

    gsub_file 'config/puma.rb',
              'plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]',
              'plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"] || Rails.env.development?'
  end

  def use_mission_control
    gem 'mission_control-jobs'
    Bundler.with_unbundled_env { run 'bundle install' }
    inject_into_file 'config/environments/development.rb', before: /^end/ do
      "  config.mission_control.jobs.http_basic_auth_enabled = false\n"
    end
    route 'mount MissionControl::Jobs::Engine, at: "/jobs"'
  end

  def run_spotlight_migrations
    rake 'spotlight:install:migrations'
    rake 'db:migrate'
  end

  def add_spotlight_routes_and_assets
    generate :'spotlight:install', '-f --mailer_default_url_host=localhost:3000 --test'
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
    append_to_file 'config/initializers/assets.rb', "\nRails.application.config.assets.precompile += %w( application_modern.css )"

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
