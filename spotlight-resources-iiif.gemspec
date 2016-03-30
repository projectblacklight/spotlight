# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spotlight/resources/iiif/version'

Gem::Specification.new do |spec|
  spec.name          = "spotlight-resources-iiif"
  spec.version       = Spotlight::Resources::Iiif::VERSION
  spec.authors       = ["Naomi Dushay", "Peter Mangiafico"]
  spec.email         = ["ndushay@stanford.edu", "petucket@stanford.edu"]

  spec.summary       = 'Spotlight Resource Indexer for IIIF manifests or collections.'
  spec.homepage      = "https://github.com/sul-dlss/spotlight-resources-iiif"
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "blacklight-spotlight"
  spec.add_dependency "faraday"
  spec.add_dependency "iiif-presentation"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'factory_girl_rails'
  spec.add_development_dependency 'database_cleaner', '~> 1.3'
#  spec.add_development_dependency 'poltergeist', '>= 1.5.0' # for js testing using phantomjs
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency 'rubocop', '~> 0.37.2'
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "engine_cart"
  spec.add_development_dependency "jettywrapper"
  spec.add_development_dependency 'exhibits_solr_conf'
  # FIXME: we shouldn't need explicit sitemap_generator dependency here as it should come with spotlight
  #   but travis fails without it (though tests run fine locally)
  # cbeer:  "we’re injecting the dependency into the host app. maybe we’re just
  #   missing a `bundle install` somewhere to fix that up"
  spec.add_development_dependency 'sitemap_generator'
end
