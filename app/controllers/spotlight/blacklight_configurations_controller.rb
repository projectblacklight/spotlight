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
