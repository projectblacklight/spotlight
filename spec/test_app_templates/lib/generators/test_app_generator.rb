require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "../../spec/test_app_templates"

  def add_gems
    gem 'blacklight', ">= 5.4.0.rc1", "<6"
    gem "blacklight-gallery", ">= 0.1.1"
    gem "sir_trevor_rails", github: "sul-dlss/sir-trevor-rails"
    gem "jettywrapper"
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)

    generate 'blacklight:install', '--devise'
  end

  def run_spotlight_migrations
    rake "spotlight:install:migrations"
    rake "db:migrate"
  end

  def add_spotlight_routes_and_assets
    generate 'spotlight:install', '--mailer_default_url_host=localhost:3000'
  end

  def install_test_catalog_controller
    copy_file "catalog_controller.rb", "app/controllers/catalog_controller.rb", force: true
  end

  def add_rake_tasks_to_app
    rakefile 'spotlight_test.rake', File.read(find_in_source_paths('spotlight_test.rake'))
  end
end
