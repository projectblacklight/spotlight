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
      blacklight_config.default_solr_params["f.#{Spotlight::SolrDocument.exhibit_slug_field}.facet.limit"] = -1
      blacklight_config.add_index_field Spotlight::SolrDocument.exhibit_slug_field, helper_method: :render_exhibit_title
      blacklight_config.add_facet_field Spotlight::SolrDocument.exhibit_slug_field, helper_method: :render_exhibit_title_facet
      previous_actions = blacklight_config.index.collection_actions.to_h.dup
      blacklight_config.index.collection_actions.clear

      blacklight_config.add_results_collection_tool('group_toggle')
      blacklight_config.index.collection_actions = blacklight_config.index.collection_actions.merge(previous_actions)
    end

    before_action do
      if render_grouped_response?
        blacklight_config.index.collection_actions.delete(:per_page_widget)

        blacklight_config.sort_fields.clear
        blacklight_config.add_sort_field(key: 'index', sort: '')
        blacklight_config.add_sort_field(key: 'count', sort: '')

        if params[:sort] == 'index'
          blacklight_config.facet_fields[Spotlight::SolrDocument.exhibit_slug_field].sort = 'index'
        else
          blacklight_config.facet_fields[Spotlight::SolrDocument.exhibit_slug_field].sort = 'count'
        end
      end
    end

    helper_method :show_pagination?, :document_index_path_templates, :render_grouped_response?, :render_grouped_document_index, :opensearch_catalog_url, :link_to_document, :url_for_document, :exhibit_metadata, :render_exhibit_title, :render_exhibit_title_facet

    def show_pagination?(*args)
      return false if render_grouped_response?

      @response.limit_value > 0
    end

    def document_index_path_templates
      [
        ("exhibit_%{index_view_type}" if render_grouped_response?),
        "document_%{index_view_type}",
        "catalog/document_%{index_view_type}",
        "catalog/document_list"
      ].compact
    end

    def render_grouped_response?(*args)
      params[:group]
    end

    def render_grouped_document_index
      slugs = @response.aggregations[Spotlight::SolrDocument.exhibit_slug_field].items.map(&:value)
      exhibits = Spotlight::Exhibit.where(slug: slugs).sort_by { |e| slugs.index e.slug }
      view_context.render_document_index(exhibits)
    end

    def opensearch_catalog_url(*args)
      spotlight.opensearch_search_across_url(*args)
    end

    # TODO
    def url_for_document(doc)
      if doc[Spotlight::SolrDocument.exhibit_slug_field].many?
        '#'
      else
        exhibit_id = doc.first(Spotlight::SolrDocument.exhibit_slug_field)
        spotlight.exhibit_solr_document_path(exhibit_id, doc.id)
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
        view_context.link_to label, url_for_document(doc), view_context.send(:document_link_params, doc, opts)
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
