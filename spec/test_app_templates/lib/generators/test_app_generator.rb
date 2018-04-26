require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root '../spec/test_app_templates'

  def use_capybara3
    gsub_file 'Gemfile', /gem 'capybara'/, '# gem \'capybara\''
  end

  def add_gems
    gem 'blacklight', '~> 6.0'
    gem 'blacklight-gallery', '>= 0.3.0'
    Bundler.with_clean_env do
      run 'bundle install'
    end
  end

  def run_blacklight_generator
    say_status('warning', 'GENERATING BL', :yellow)

    generate 'blacklight:install', '--devise'
  end

  def run_spotlight_migrations
    rake 'spotlight:install:migrations'
    rake 'db:migrate'
  end

  def add_spotlight_routes_and_assets
    generate 'spotlight:install', '-f --mailer_default_url_host=localhost:3000'
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
end
