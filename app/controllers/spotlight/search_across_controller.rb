# frozen_string_literal: true

module Spotlight
  ##
  # Spotlight's catalog controller. Note that this subclasses
  # the host application's CatalogController to get its configuration,
  # partial overrides, etc
  # rubocop:disable Metrics/ClassLength
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

    def url_for_document(doc)
      '#'
    end

    # TODO: this will require that the slug facet returns all values
    def exhibit_slugs
      @exhibit_slugs ||= (@response.dig('facet_counts', 'facet_fields', Spotlight::SolrDocument.exhibit_slug_field) || []).select do |facet|
        facet.is_a?(String) # we should find a better way to do this
      end
    end

    def exhibit_metadata
      @exhibit_metadata ||= Spotlight::Exhibit.where(slug: exhibit_slugs).accessible_by(current_ability).as_json(only: [:slug, :title, :description, :id]).index_by { |x| x['slug'] }
    end

    def exhibit_title(document:, value:, **)
      view_context.safe_join exhibit_metadata.slice(*value).values.map { |x| view_context.link_to x['title'] || x['slug'], spotlight.exhibit_solr_document_path(x['slug'], document.id) }, ', '
    end

    def exhibit_title_facet(value)
      exhibit_metadata.slice(*value).values.map { |x| x['title'] || x['slug'] }.join(', ')
    end

    # todo: scope to published exhibits only
  end
end
