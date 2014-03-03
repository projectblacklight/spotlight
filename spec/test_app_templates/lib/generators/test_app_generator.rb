require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "../../spec/test_app_templates"

  def add_gems
    gem 'blacklight', '~> 5.1'     
    gem "blacklight-gallery", :github => 'projectblacklight/blacklight-gallery'
    gem 'sir-trevor-rails', :github => 'sul-dlss/sir-trevor-rails'
    gem "jettywrapper"
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)  

    generate 'blacklight:install', '--devise'
    copy_file "catalog_controller.rb", "app/controllers/catalog_controller.rb", force: true
  end

  def run_spotlight_migrations
    rake "spotlight:install:migrations"
    rake "db:migrate"
  end

  def add_spotlight_routes_and_assets
    generate 'spotlight:install'
  end

  def add_rake_tasks_to_app
    rakefile 'spotlight_test.rake', File.read(find_in_source_paths('spotlight_test.rake'))
  end

  def add_mailer_defaults
    mail_config = "    config.action_mailer.default_url_options = { host: \"localhost:3000\", from: \"noreply@example.com\" }\n"
    insert_into_file 'config/application.rb', mail_config, after: "< Rails::Application\n"
  end
end
