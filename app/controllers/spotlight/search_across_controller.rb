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
      blacklight_config.add_index_field :spotlight_exhibit_slugs_ssim
      blacklight_config.add_facet_field :spotlight_exhibit_slugs_ssim
    end

    helper_method :opensearch_catalog_url, :url_for_document

    def opensearch_catalog_url(*args)
      spotlight.opensearch_search_across_url(*args)
    end

    def url_for_document(doc)
      '#'
    end

    # todo: scope to published exhibits only
  end
end
