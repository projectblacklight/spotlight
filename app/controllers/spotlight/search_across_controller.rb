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
      blacklight_config.index.document_presenter_clas = SearchAcrossIndexPresenter
      blacklight_config.search_builder_class = SearchAcrossSearchBuilder
      blacklight_config.track_search_session = false
      blacklight_config.add_index_field Spotlight::SolrDocument.exhibit_slug_field, helper_method: :render_exhibit_title
      blacklight_config.add_facet_field Spotlight::SolrDocument.exhibit_slug_field, helper_method: :render_exhibit_title_facet
    end

    helper_method :opensearch_catalog_url, :link_to_document, :url_for_document, :exhibit_metadata, :render_exhibit_title, :render_exhibit_title_facet

    def opensearch_catalog_url(*args)
      spotlight.opensearch_search_across_url(*args)
    end

    # TODO
    def url_for_document(doc)
      if doc[Spotlight::SolrDocument.exhibit_slug_field].many?
        '#'
      else
        exhibit_id = doc.first(Spotlight::SolrDocument.exhibit_slug_field)
        spotlight.exhibit_solr_document_path(exhibit_id, document.id)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def link_to_document(doc, field_or_opts, opts = { counter: nil })
      label = case field_or_opts
              when NilClass
                view_context.index_presenter(doc).heading
              when Hash
                opts = field_or_opts
                view_context.index_presenter(doc).heading
              when Proc, Symbol
                Deprecation.warn(self, "passing a #{field_or_opts.class} to link_to_document is deprecated and will be removed in Blacklight 8")
                Deprecation.silence(Blacklight::IndexPresenter) do
                  view_context.index_presenter(doc).label field_or_opts, opts
                end
              else # String
                field_or_opts
              end

      if doc[Spotlight::SolrDocument.exhibit_slug_field].many?
        label
      else
        link_to label, url_for_document(doc), document_link_params(doc, opts)
      end
    end
    # rubocop:enable Metrics/MethodLength

    def exhibit_slugs
      @response.documents.flat_map { |x| x[Spotlight::SolrDocument.exhibit_slug_field] }.uniq
    end

    def accessible_exhibits_from_search_results
      Spotlight::Exhibit.where(slug: exhibit_slugs).accessible_by(current_ability)
    end

    def exhibit_metadata
      @exhibit_metadata ||= accessible_exhibits_from_search_results.as_json(only: %i[slug title description id]).index_by { |x| x['slug'] }
    end

    def render_exhibit_title(document:, value:, **)
      exhibit_links = exhibit_metadata.slice(*value).values.map do |x|
        view_context.link_to x['title'] || x['slug'], spotlight.exhibit_solr_document_path(x['slug'], document.id)
      end

      view_context.safe_join exhibit_links, ', '
    end

    def render_exhibit_title_facet(value)
      exhibit_metadata.slice(*value).values.map { |x| x['title'] || x['slug'] }.join(', ')
    end
  end
end
