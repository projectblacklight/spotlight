class Spotlight::ExhibitsController < Spotlight::ApplicationController
  before_filter :authenticate_user!
  before_filter :default_exhibit
  include Blacklight::SolrHelper

  authorize_resource

  def edit
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

  def update
    if @exhibit.update(exhibit_params)
      redirect_to main_app.root_path, notice: "The exhibit was saved."
    else
      render action: :edit
    end
  end

  protected

  def exhibit_params
    params.require(:exhibit).permit(
      :title,
      :subtitle,
      :description,
      contact_emails_attributes: [:email],
      blacklight_configuration_attributes: [
        facet_fields: [exhibit_configuration_facet_params],
        index_fields: [exhibit_configuration_index_params]
      ]
    )
  end

  def exhibit_configuration_index_params
    views = @exhibit.blacklight_configuration.default_blacklight_config.view.keys | [:show]

    @exhibit.blacklight_configuration.default_blacklight_config.index_fields.keys.inject({}) { |result, element| result[element] = ([:enabled] | views); result }
  end

  def exhibit_configuration_facet_params
    @exhibit.blacklight_configuration.default_blacklight_config.facet_fields.keys.inject({}) { |result, element| result[element] = [:enabled, :label]; result }
  end

  def default_exhibit
    @exhibit = Spotlight::Exhibit.default
  end
end
