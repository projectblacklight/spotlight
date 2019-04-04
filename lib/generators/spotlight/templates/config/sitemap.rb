# frozen_string_literal: true

require 'sitemap_generator'

# TODO: Update the default host to match your deployment environment
SitemapGenerator::Sitemap.default_host = 'http://localhost/'

SitemapGenerator::Interpreter.send :include, Rails.application.routes.url_helpers
SitemapGenerator::Interpreter.send :include, Spotlight::Engine.routes.url_helpers

SitemapGenerator::Sitemap.create do
  Spotlight::Sitemap.add_all_exhibits(self)
end
