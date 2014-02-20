class Spotlight::CustomFieldsController < Spotlight::ApplicationController
  before_filter :authenticate_user!
  
  load_resource :exhibit, class: Spotlight::Exhibit, only: [:index, :new, :create]
  load_and_authorize_resource through: :exhibit, only: [:index, :new, :create]

  load_and_authorize_resource only: [:edit, :update, :destroy]
  before_filter :attach_breadcrumbs, only: [:new, :edit]

  def new
    add_breadcrumb t(:'helpers.action.spotlight/custom_field.create'), new_exhibit_custom_field_path(@exhibit)

  end

  def edit
    add_breadcrumb @custom_field.label, edit_custom_field_path(@custom_field)
  end

  def create
    @custom_field.attributes = custom_field_params
    @custom_field.exhibit = current_exhibit

    if @custom_field.save
      redirect_to exhibit_edit_metadata_path(@custom_field.exhibit), alert: "Custom field was created"
    else
      render action: 'new'
    end
  end

  def update
    if @custom_field.update custom_field_params
      redirect_to exhibit_edit_metadata_path(@custom_field.exhibit), alert: "Custom field was updated"
    else
      render action: 'edit'
    end
  end

  def destroy
    @custom_field.destroy
    redirect_to exhibit_edit_metadata_path(@custom_field.exhibit), alert: "Custom field was deleted"
  end

  protected

  def attach_breadcrumbs
    load_exhibit
    add_breadcrumb @exhibit.title, @exhibit
    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'spotlight.blacklight_configurations.edit_metadata_fields.header'), exhibit_edit_metadata_path(@exhibit)
  end

  def load_exhibit
    @exhibit ||= @custom_field.exhibit
  end

  def custom_field_params
    params.require(:custom_field).permit(:label, :short_description)
  end
end
