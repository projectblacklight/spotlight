# frozen_string_literal: true

module Spotlight
  ##
  # Spotlight's catalog controller. Note that this subclasses
  # the host application's CatalogController to get its configuration,
  # partial overrides, etc
  class SearchAcrossController < ::CatalogController
    include Blacklight::Catalog
    include Spotlight::Catalog

    layout 'spotlight/home'

    def blacklight_config
      @blacklight_config ||= self.class.blacklight_config.deep_copy
    end

    configure_blacklight do
      blacklight_config.track_search_session = false
      blacklight_config.add_index_field Spotlight::SolrDocument.exhibit_slug_field, helper_method: :exhibit_title
      blacklight_config.add_facet_field Spotlight::SolrDocument.exhibit_slug_field, helper_method: :exhibit_title_facet
    end

    helper_method :opensearch_catalog_url, :url_for_document, :exhibit_metadata, :exhibit_title, :exhibit_title_facet

    def opensearch_catalog_url(*args)
      spotlight.opensearch_search_across_url(*args)
    end

    # TODO
    def url_for_document(_)
      '#'
    end

    # TODO: Limit just to the exhibits we care about
    def exhibit_metadata
      @exhibit_metadata ||= Spotlight::Exhibit.all.as_json(only: [:slug, :title, :description]).index_by { |x| x['slug'] }
    end

    def exhibit_title(value:, **)
      exhibit_metadata.slice(*value).values.map { |x| x['title'] || x['slug'] }.join(', ')
    end

    def exhibit_title_facet(value)
      exhibit_metadata.slice(*value).values.map { |x| x['title'] || x['slug'] }.join(', ')
    end

    # todo: scope to published exhibits only
  end
end
