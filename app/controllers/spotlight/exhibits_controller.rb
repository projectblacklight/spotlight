class Spotlight::ExhibitsController < Spotlight::ApplicationController
  before_filter :default_exhibit
  authorize_resource

  def edit
  end

  def edit_metadata_fields
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
    params.require(:exhibit).permit(:title, :subtitle, :description, { blacklight_configuration_attributes: [facet_fields: [], index_fields: [@exhibit.blacklight_configuration.default_blacklight_config.document_index_view_types.inject({}) { |result, element| result[element] = []; result }], show_fields: [], search_fields: [], sort_fields: [], default_solr_params: [], show: [], index: [], per_page: [], document_index_view_types: [] ] }, contact_emails_attributes: [:email])
  end

  def default_exhibit
    @exhibit = Spotlight::Exhibit.default
  end
end
