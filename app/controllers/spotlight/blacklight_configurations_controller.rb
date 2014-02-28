class Spotlight::BlacklightConfigurationsController < Spotlight::ApplicationController
  before_filter :authenticate_user!
  load_resource :exhibit, class: Spotlight::Exhibit
  load_and_authorize_resource through: :exhibit, singleton: true

  include Blacklight::SolrHelper

  def update
    if @blacklight_configuration.update(exhibit_params)
      redirect_to main_app.root_path, notice: "The exhibit was saved."
    else
      redirect_to [:edit, @exhibit]
    end
  end

  def metadata_fields
    respond_to do |format|
      format.json { render json: @blacklight_configuration.blacklight_config.index_fields.as_json }
    end
  end

  ##
  # Edit the index and show view metadata fields
  def edit_metadata_fields
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'spotlight.curation.sidebar.metadata'), exhibit_edit_metadata_path(@exhibit)
  end

  ##
  # Edit the index and show view metadata fields
  def edit_facet_fields
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'spotlight.curation.sidebar.search_facets'), exhibit_edit_facets_path(@exhibit)
    @fields = blacklight_solr.get('admin/luke', params: { fl: '*', 'json.nl' => 'map' })['fields']
  end

  # the luke request handler can return document counts, but the seem to be incorrect.
  # They seem to be for the whole index and they decrease after optimizing.
  # This method finds those counts by doing regular facet queries
  def alternate_count
    @alt_count ||= begin
      facet_query = @blacklight_configuration.blacklight_config.facet_fields.keys.map { |key| "#{key}:[* TO *]" }
      solr_resp = blacklight_solr.get('select', params: {'facet.query' => facet_query, 'rows' =>0})
      @alt_count = solr_resp['facet_counts']['facet_queries'].each_with_object({}) do |(key, val), alt_count|
        alt_count[key.split(/:/).first] = val
      end
    end
  end

  helper_method :alternate_count

  protected

  def exhibit_params
    params.require(:blacklight_configuration).permit(
      facet_fields: [exhibit_configuration_facet_params],
      index_fields: [exhibit_configuration_index_params]
    )
  end

  def exhibit_configuration_index_params
    views = @blacklight_configuration.default_blacklight_config.view.keys | [:show]

    @blacklight_configuration.blacklight_config.index_fields.keys.inject({}) { |result, element| result[element] = ([:enabled, :label, :weight] | views); result }
  end

  def exhibit_configuration_facet_params
    @blacklight_configuration.blacklight_config.facet_fields.keys.inject({}) { |result, element| result[element] = [:show, :label, :weight]; result }
  end

end
