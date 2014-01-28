require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root "spec/test_app_templates"

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)       

    generate 'blacklight', '--devise'
  end

  def run_spotlight_migrations
    rake "spotlight:install:migrations"
    rake "db:migrate"
  end

  def add_spotlight_routes_and_assets
    generate 'spotlight:install'
  end
end
