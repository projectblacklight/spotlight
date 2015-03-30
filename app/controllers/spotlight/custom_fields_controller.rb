class Spotlight::CustomFieldsController < Spotlight::ApplicationController
  before_filter :authenticate_user!
  
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  load_and_authorize_resource through: :exhibit
  before_filter :attach_breadcrumbs, only: [:new, :edit]

  def new
    @custom_field.field_type ||= "text"
    add_breadcrumb t(:'helpers.action.spotlight/custom_field.create'), new_exhibit_custom_field_path(@exhibit)
  end

  def edit
    add_breadcrumb @custom_field.label, edit_exhibit_custom_field_path(@custom_field.exhibit, @custom_field)
  end

  def create
    @custom_field.attributes = custom_field_params
    @custom_field.exhibit = current_exhibit

    if @custom_field.save
      redirect_to exhibit_edit_metadata_path(@custom_field.exhibit), notice: t(:'helpers.submit.custom_field.created', model: @custom_field.class.model_name.human.downcase)
    else
      render action: 'new'
    end
  end

  def update
    if @custom_field.update custom_field_params
      redirect_to exhibit_edit_metadata_path(@custom_field.exhibit), notice: t(:'helpers.submit.custom_field.updated', model: @custom_field.class.model_name.human.downcase)
    else
      render action: 'edit'
    end
  end

  def destroy
    @custom_field.destroy
    redirect_to exhibit_edit_metadata_path(@custom_field.exhibit), notice: t(:'helpers.submit.custom_field.destroyed', model: @custom_field.class.model_name.human.downcase)
  end

  protected

  def attach_breadcrumbs
    add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
    add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
    add_breadcrumb t(:'spotlight.blacklight_configurations.edit_metadata_fields.header'), exhibit_edit_metadata_path(@exhibit)
  end

  def custom_field_params
    params.require(:custom_field).permit(:label, :short_description, :field_type)
  end
end
