module Spotlight::HomePagesHelper
  include Blacklight::UrlHelperBehavior

  ##
  # Standard display of a facet value in a list. Used in both _facets sidebar
  # partial and catalog/facet expanded list. Will output facet value name as
  # a link to add that to your restrictions, with count in parens.
  #
  # @param [Blacklight::SolrResponse::Facets::FacetField]
  # @param [String] facet item
  # @param [Hash] options
  # @option options [Boolean] :suppress_link display the facet, but don't link to it
  # @option options [Rails::Engine] :route_set route set to use to render the link
  # @return [String]
  def render_facet_value(facet_solr_field, item, options ={})    
    scope = options.delete(:route_set) || main_app
    path = scope.catalog_index_url(add_facet_params_and_redirect(facet_solr_field, item).merge(only_path: true))
    content_tag(:span, :class => "facet-label") do
      link_to_unless(options[:suppress_link], facet_display_value(facet_solr_field, item), path, :class=>"facet_select")
    end + render_facet_count(item.hits)
  end
end