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

  # When the test app is generated with the Rails-provided Dockerfile (i.e. without --skip-docker),
  # make it buildable. Build it with the engine available as a named context, e.g.:
  #   docker build --build-context spotlight=.. .
  def configure_dockerfile
    return unless File.exist?('Dockerfile')

    gsub_file 'Dockerfile', ' libjemalloc2', ' imagemagick libjemalloc2'
    # The translation initializer queries the database, which isn't available while precompiling assets
    gsub_file 'Dockerfile', 'SECRET_KEY_BASE_DUMMY=1 ', 'SECRET_KEY_BASE_DUMMY=1 SKIP_TRANSLATION=yes '
  end

  def copy_engine_into_docker_image
    return unless File.exist?('Dockerfile')

    # The Gemfile references the engine by its absolute path, so copy it to the same path in the image
    engine_root = Spotlight::Engine.root
    insert_into_file 'Dockerfile', before: "# Install application gems\n" do
      <<~DOCKERFILE
        # Install the local Spotlight engine referenced from the Gemfile
        COPY --from=spotlight blacklight-spotlight.gemspec #{engine_root}/
        COPY --from=spotlight spec/test_app_templates/Gemfile.extra #{engine_root}/spec/test_app_templates/
        #{%w[app config db lib vendor].map { |dir| "COPY --from=spotlight #{dir} #{engine_root}/#{dir}" }.join("\n")}

      DOCKERFILE
    end
  end

  def use_engine_in_docker_image
    return unless File.exist?('Dockerfile')

    engine_root = Spotlight::Engine.root
    # Stand in for the `yarn link spotlight-frontend` the test app uses locally
    insert_into_file 'Dockerfile', after: "RUN yarn install --immutable\n" do
      "RUN ln -s #{engine_root} node_modules/spotlight-frontend\n"
    end

    # Make the engine available at runtime too
    insert_into_file 'Dockerfile', after: %r{^COPY .*--from=build /rails /rails\n} do
      "COPY --from=build #{engine_root} #{engine_root}\n"
    end
  end

  def raise_on_missing_translation
    uncomment_lines 'config/environments/development.rb', /config.action_view.raise_on_missing_translations/
    uncomment_lines 'config/environments/test.rb', /config.action_view.raise_on_missing_translations/
  end
end
