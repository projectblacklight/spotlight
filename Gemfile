source 'https://rubygems.org'

# Specify your gem's dependencies in spotlight-resources-iiif.gemspec
gemspec

# BEGIN ENGINE_CART BLOCK
# engine_cart: 0.8.0
# engine_cart stanza: 0.8.0
# the below comes from engine_cart, a gem used to test this Rails engine gem in the context of a Rails app.
file = File.expand_path("Gemfile", ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path(".internal_test_app", File.dirname(__FILE__)))
if File.exist?(file)
  begin
    eval_gemfile file
  rescue Bundler::GemfileError => e
    Bundler.ui.warn '[EngineCart] Skipping Rails application dependencies:'
    Bundler.ui.warn e.message
  end
else
  Bundler.ui.warn "[EngineCart] Unable to find test application dependencies in #{file}, using placeholder dependencies"

  gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

  if ENV['RAILS_VERSION'].nil? || ENV['RAILS_VERSION'] =~ /^4.2/
    gem 'responders', "~> 2.0"
    gem 'sass-rails', ">= 5.0"
  else
    gem 'sass-rails', "< 5.0"
  end
end
# END ENGINE_CART BLOCK
gem 'blacklight-spotlight', github: 'projectblacklight/spotlight'
