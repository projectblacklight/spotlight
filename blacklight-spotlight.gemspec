# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'spotlight/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = 'blacklight-spotlight'
  s.version = Spotlight::VERSION
  s.authors = ['Chris Beer', 'Jessie Keck', 'Gary Geisler', 'Justin Coyne']
  s.email = ['exhibits-feedback@lists.stanford.edu']
  s.homepage = 'https://github.com/projectblacklight/spotlight'
  s.summary = %(Enable librarians, curators, and others who are responsible
for digital collections to create attractive, feature-rich websites that feature
these collections.)

  s.files = Dir['{app,config,db,lib,vendor}/**/*', 'Rakefile', 'README.md', 'LICENSE', 'spec/{factories,fixtures}/*', 'spec/support/**/*']

  s.required_ruby_version = '>= 3.1'

  s.add_dependency 'activejob-status'
  s.add_dependency 'acts-as-taggable-on', '>= 5.0', '< 12'
  s.add_dependency 'autoprefixer-rails'
  s.add_dependency 'blacklight', '>= 7.40', '< 9'
  s.add_dependency 'blacklight-gallery', '>= 3.0', '< 4.7.0'
  s.add_dependency 'bootstrap_form', '>= 4.1', '< 6'
  s.add_dependency 'cancancan'
  s.add_dependency 'carrierwave', '~> 2.2'
  s.add_dependency 'clipboard-rails', '~> 1.5'
  s.add_dependency 'csv'
  s.add_dependency 'devise', '~> 4.9'
  s.add_dependency 'devise_invitable'
  s.add_dependency 'faraday'
  s.add_dependency 'faraday-follow_redirects'
  s.add_dependency 'friendly_id', '~> 5.5'
  s.add_dependency 'github-markup'
  s.add_dependency 'google-analytics-data'
  s.add_dependency 'i18n'
  s.add_dependency 'i18n-active_record'
  s.add_dependency 'iiif_manifest'
  s.add_dependency 'iiif-presentation'
  s.add_dependency 'leaflet-rails'
  s.add_dependency 'mini_magick'
  s.add_dependency 'nokogiri'
  s.add_dependency 'oauth2'
  s.add_dependency 'openseadragon', '0.9.0'
  s.add_dependency 'ostruct', '!= 0.3.0', '!= 0.3.1', '!= 0.3.2'
  s.add_dependency 'paper_trail', '>= 11.0', '< 16'
  s.add_dependency 'rails', '>= 7.0', '< 8'
  s.add_dependency 'redcarpet', '>= 2.0.1', '< 4'
  s.add_dependency 'riiif', '~> 2.0'
  s.add_dependency 'roar', '~> 1.1'
  s.add_dependency 'roar-rails'
  s.add_dependency 'signet'
  s.add_dependency 'tophat'
  s.add_dependency 'view_component', '>= 2.66', '< 4'

  s.add_development_dependency 'capybara', '~> 3.31'
  s.add_development_dependency 'engine_cart', '~> 2.0'
  s.add_development_dependency 'factory_bot', '~> 6.0'
  s.add_development_dependency 'i18n-tasks'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rspec-collection_matchers'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'rspec-rails', '>= 4.0.0.beta1'
  s.add_development_dependency 'rubocop', '~> 1.8'
  s.add_development_dependency 'rubocop-capybara'
  s.add_development_dependency 'rubocop-rails'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov', '~> 0.12'
  s.add_development_dependency 'sitemap_generator'
  s.add_development_dependency 'solr_wrapper'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'webmock'
  s.metadata['rubygems_mfa_required'] = 'true'
end
