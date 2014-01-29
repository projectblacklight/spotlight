$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spotlight/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spotlight"
  s.version     = Spotlight::VERSION
  s.authors     = ["Chris Beer", "Jessie Keck", "Gary Geisler", "Justin Coyne"]
  s.email       = ["exhibits-feedback@lists.stanford.edu"]
  s.homepage    = "https://github.com/sul-dlss/spotlight"
  s.summary     = "Enable librarians, curators,   and others who are responsible for digital collections to create   attractive, feature-rich websites that feature these collections."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.1"
  s.add_dependency "blacklight"
  s.add_dependency "cancan"
  s.add_dependency "sir-trevor-rails"
  s.add_dependency "carrierwave"
  s.add_dependency "mini_magick"
  s.add_dependency "bootstrap_form"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "poltergeist"
  s.add_development_dependency "engine_cart", ">= 0.1.3"
  s.add_development_dependency "jettywrapper"
end
