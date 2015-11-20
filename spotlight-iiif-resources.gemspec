# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spotlight/iiif/resources/version'

Gem::Specification.new do |spec|
  spec.name          = "spotlight-iiif-resources"
  spec.version       = Spotlight::Iiif::Resources::VERSION
  spec.authors       = ["Naomi Dushay"]
  spec.email         = ["ndushay@stanford.edu"]

  spec.summary       = 'Spotlight Resource Indexer for IIIF manifests or collections.'
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/sul-dlss/spotlight-iiif-resources"
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "yard"
end
