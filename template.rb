gem "blacklight", '>= 5.11.2'
gem "blacklight-spotlight", ENV['SPOTLIGHT_GEM'] ? { path: ENV['SPOTLIGHT_GEM'] } : { github: 'sul-dlss/spotlight' }
gem "sir_trevor_rails", github: 'madebymany/sir-trevor-rails'

run "bundle install"

# run the blacklight install generator
blacklight_options = ENV.fetch("BLACKLIGHT_INSTALL_OPTIONS", '--devise --jettywrapper')
generate 'blacklight:install', blacklight_options

spotlight_options = ENV.fetch("SPOTLIGHT_INSTALL_OPTIONS", '-f --openseadragon --mailer_default_url_host=localhost:3000')
generate 'spotlight:install', spotlight_options
rake "spotlight:install:migrations"

if !self.options["quiet"] and yes? "Would you like to create an initial administrator?"
  rake "db:migrate"  # we only need to run the migrations if we are creating an admin user
  rake "spotlight:initialize"
end

# index some data
if blacklight_options =~ /jettywrapper/
  rake "jetty:configure_solr"
end
