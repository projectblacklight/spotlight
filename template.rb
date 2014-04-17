gem "blacklight"
gem "blacklight-gallery", :github => 'projectblacklight/blacklight-gallery'
gem "blacklight-spotlight", :github => 'sul-dlss/spotlight'
gem 'sir-trevor-rails', :github => 'sul-dlss/sir-trevor-rails'
gem 'openseadragon', :github => 'sul-dlss/openseadragon-rails'
gem "jettywrapper"

run "bundle install"

generate 'blacklight:install', '--devise'
generate 'blacklight_gallery:install'
generate 'spotlight:install'
rake "spotlight:install:migrations"
rake "db:migrate"

rake "spotlight:initialize"