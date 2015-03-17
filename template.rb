gem "blacklight", '>= 5.10'
gem "blacklight-spotlight", github: 'sul-dlss/spotlight'
gem "sir_trevor_rails", github: 'madebymany/sir-trevor-rails'

run "bundle install"

# run the blacklight install generator
blacklight_options = ENV.fetch("BLACKLIGHT_INSTALL_OPTIONS", '--devise --jettywrapper')
generate 'blacklight:install', blacklight_options

spotlight_options = ENV.fetch("SPOTLIGHT_INSTALL_OPTIONS", '--openseadragon --mailer_default_url_host=localhost:3000')
generate 'spotlight:install', spotlight_options
rake "spotlight:install:migrations"
rake "db:migrate"

rake "spotlight:initialize"

# index some data
if blacklight_options =~ /jettywrapper/
  rake "jetty:configure_solr"
end
