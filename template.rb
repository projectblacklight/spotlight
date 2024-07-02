# frozen_string_literal: true

require 'bundler'

DEFAULT_BLACKLIGHT_OPTIONS = '--devise'
DEFAULT_SPOTLIGHT_OPTIONS = '-f --openseadragon --mailer_default_url_host=localhost:3000'
blacklight_options = ENV.fetch('BLACKLIGHT_INSTALL_OPTIONS', DEFAULT_BLACKLIGHT_OPTIONS)
spotlight_options = ENV.fetch('SPOTLIGHT_INSTALL_OPTIONS', DEFAULT_SPOTLIGHT_OPTIONS)

# Add gem dependencies to the application
gem 'blacklight', ' ~> 7.0'
gem 'blacklight-spotlight', ENV['SPOTLIGHT_GEM'] ? { path: ENV['SPOTLIGHT_GEM'] } : { github: 'projectblacklight/spotlight' }
gem 'sidekiq'

Bundler.with_clean_env do
  run 'bundle install'
end

# run the blacklight install generator
generate 'blacklight:install', blacklight_options

# run the spotlight installer
generate 'spotlight:install', spotlight_options
rake 'spotlight:install:migrations'

# create an initial administrator (if we are running interactively..)
if !options['quiet'] && yes?('Would you like to create an initial administrator?')
  rake 'db:migrate' # we only need to run the migrations if we are creating an admin user
  rake 'spotlight:initialize'
end

insert_into_file 'config/application.rb', after: "< Rails::Application\n" do
  <<-CONFIG
  config.active_job.queue_adapter = ENV["RAILS_QUEUE"]&.to_sym || :sidekiq
  CONFIG
end

after_bundle do
  # Rails installed importmap by default, but we don't have importmap + Blacklight 7 working yet.
  # Similar to step in Spotlight::Install#add_manifest, but this cleans up the file stimulus-rails
  # creates afterward.
  remove_file 'app/javascript/application.js'
end
