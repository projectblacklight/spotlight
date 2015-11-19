module Spotlight
  # Generate a sitemap for the Spotlight exhibit content
  class Sitemap
    attr_reader :sitemap, :exhibit

    ##
    # Add all (published) spotlight exhibits to the given sitemap
    #
    # @param [Sitemap::Interpreter] Sitemap instance provided by sitemap_generator
    def self.add_all_exhibits(sitemap)
      SitemapGenerator::Interpreter.send :include, Spotlight::Engine.routes.url_helpers

      Spotlight::Exhibit.published.find_each do |e|
        add_exhibit(sitemap, e)
      end
    end

    ##
    # Add a single exhibit to the given sitemap
    #
    # @param [Sitemap::Interpreter]
    # @param [Spotlight::Exhibit]
    def self.add_exhibit(sitemap, exhibit)
      sitemap = Spotlight::Sitemap.new(sitemap, exhibit)
      sitemap.add_resources!
      sitemap
    end

    ##
    # @param [Sitemap::Interpreter]
    # @param [Spotlight::Exhibit]
    def initialize(sitemap, exhibit)
      @sitemap = sitemap
      @exhibit = exhibit
    end

    ##
    # Add all exhibit resources to the sitemap
    def add_resources!
      return unless exhibit.published?

      add_exhibit_root
      add_pages
      add_resources
      add_browse_categories
    end

    ##
    # Add the exhibit home page to the sitemap
    def add_exhibit_root
      sitemap.add sitemap.exhibit_root_path(exhibit)
    end

    ##
    # Add all published feature and about pages to the sitemap
    def add_pages
      exhibit.feature_pages.published.find_each do |p|
        sitemap.add sitemap.exhibit_feature_page_path(exhibit, p), priority: 0.8, lastmod: p.updated_at
      end

      exhibit.about_pages.published.find_each do |p|
        sitemap.add sitemap.exhibit_about_page_path(exhibit, p), priority: 0.5, lastmod: p.updated_at
      end
    end

    ##
    # Add published browse categories to the sitemap
    def add_browse_categories
      exhibit.searches.published.find_each do |s|
        sitemap.add sitemap.exhibit_browse_path(exhibit, s), priority: 0.5, lastmod: s.updated_at
      end
    end

    ##
    # Add all catalog resources to the sitemap
    def add_resources
      exhibit.solr_documents.each do |d|
        sitemap.add sitemap.exhibit_catalog_path(exhibit, d), priority: 0.25, lastmod: document_last_modified(d)
      end
    end

    private

    def document_last_modified(d)
      lastmod = Time.zone.parse(d[exhibit.blacklight_config.index.timestamp_field]) if d[exhibit.blacklight_config.index.timestamp_field]
      lastmod || Time.zone.now
    end
  end
end
