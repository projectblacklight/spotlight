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

  s.add_dependency "rails", "~> 4.0", ">= 4.2.0"
  s.add_dependency "blacklight", "~> 5.8"
  s.add_dependency "autoprefixer-rails"
  s.add_dependency "cancancan"
  s.add_dependency "sir_trevor_rails", ">= 0.5.0a"
  s.add_dependency "carrierwave"
  s.add_dependency "carrierwave-crop"
  s.add_dependency "mini_magick"
  s.add_dependency "bootstrap_form", "~> 2.2.0"
  s.add_dependency "mail_form"
  s.add_dependency "acts-as-taggable-on", "3.1.0"
  s.add_dependency "friendly_id", "5.1.0"
  s.add_dependency "breadcrumbs_on_rails", "~> 2.3.0"
  s.add_dependency "social-share-button", "~> 0.1.5"
  s.add_dependency "blacklight-oembed", ">= 0.0.3"
  s.add_dependency "devise", "~> 3.0"
  s.add_dependency "roar-rails"
  s.add_dependency "faraday"
  s.add_dependency "faraday_middleware"
  s.add_dependency "nokogiri"
  s.add_dependency "underscore-rails", "~> 1.6.0"
  s.add_dependency "github-markup"
  s.add_dependency "lodash-rails"
  s.add_dependency "tophat"
  s.add_dependency "legato"
  s.add_dependency "google-api-client"
  s.add_dependency "oauth2"
  s.add_dependency "paper_trail", '~> 4.0.0.beta'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails", "~> 3.1"
  s.add_development_dependency "rspec-its"
  s.add_development_dependency "rspec-activemodel-mocks"
  s.add_development_dependency "rspec-collection_matchers"
  s.add_development_dependency "capybara"
  s.add_development_dependency "poltergeist", ">= 1.5.0"
  s.add_development_dependency "factory_girl", "~> 4.5"
  s.add_development_dependency "engine_cart", "~> 0.6.0"
  s.add_development_dependency "database_cleaner", "1.3.0"
  s.add_development_dependency "jettywrapper"
end
