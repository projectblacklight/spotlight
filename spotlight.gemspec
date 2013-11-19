$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "spotlight/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "spotlight"
  s.version     = Spotlight::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Spotlight."
  s.description = "TODO: Description of Spotlight."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.1"
  s.add_dependency "blacklight"
  s.add_dependency "cancan"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "poltergeist"
  s.add_development_dependency "engine_cart", ">= 0.1.2"
  s.add_development_dependency "jettywrapper"
end
