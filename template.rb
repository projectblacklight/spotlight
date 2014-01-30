gem "blacklight"
gem "blacklight-gallery", :github => 'projectblacklight/blacklight-gallery'
gem "spotlight", :github => 'sul-dlss/spotlight'
gem 'sir-trevor-rails', :github => 'sul-dlss/sir-trevor-rails'
gem "jettywrapper"

run "bundle install"

generate 'blacklight', '--devise'
generate 'blacklight_gallery:install'
generate 'spotlight:install'
rake "spotlight:install:migrations"
rake "db:migrate"

git :init
git add: "."
git commit: "-a -m 'Initial commit'"