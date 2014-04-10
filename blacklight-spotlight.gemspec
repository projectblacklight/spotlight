$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spotlight/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "blacklight-spotlight"
  s.version     = Spotlight::VERSION
  s.authors     = ["Chris Beer", "Jessie Keck", "Gary Geisler", "Justin Coyne"]
  s.email       = ["exhibits-feedback@lists.stanford.edu"]
  s.homepage    = "https://github.com/sul-dlss/spotlight"
  s.summary     = "Enable librarians, curators,   and others who are responsible for digital collections to create   attractive, feature-rich websites that feature these collections."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.1"
  s.add_dependency "blacklight", "~> 5.2"
  s.add_dependency "blacklight-gallery"
  s.add_dependency "cancancan"
  s.add_dependency "sir-trevor-rails"
  s.add_dependency "carrierwave"
  s.add_dependency "mini_magick"
  s.add_dependency "bootstrap_form", "~> 2.0.1"
  s.add_dependency "mail_form"
  s.add_dependency "acts-as-taggable-on", "3.1.0"
  s.add_dependency "friendly_id"
  s.add_dependency "breadcrumbs_on_rails", "~> 2.3.0"
  s.add_dependency "social-share-button", "~> 0.1.5"
  s.add_dependency "ruby-oembed"
  s.add_dependency "devise", "~> 3.2.3"
  s.add_dependency "active_model_serializers", ">= 0.9.0.alpha1"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"
  s.add_dependency "nokogiri"
  s.add_dependency "openseadragon", ">= 0.0.5"
  
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "poltergeist", ">= 1.5.0"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "engine_cart", "~> 0.3.4"
  s.add_development_dependency "database_cleaner", "< 1.1.0"
  s.add_development_dependency "jettywrapper"
end
