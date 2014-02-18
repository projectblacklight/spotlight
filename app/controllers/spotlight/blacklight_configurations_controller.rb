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

  ##
  # Edit the index and show view metadata fields
  def edit_metadata_fields
  end

  ##
  # Edit the index and show view metadata fields
  def edit_facet_fields
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

    (@blacklight_configuration.all_index_fields.keys  + @blacklight_configuration.custom_index_fields.keys).inject({}) { |result, element| result[element] = ([:enabled, :label, :weight] | views); result }
  end

  def exhibit_configuration_facet_params
    @blacklight_configuration.all_facet_fields.keys.inject({}) { |result, element| result[element] = [:show, :label, :weight]; result }
  end

end