class Spotlight::CustomFieldsController < Spotlight::ApplicationController
  before_filter :authenticate_user!
  
  load_resource :exhibit, class: Spotlight::Exhibit, only: [:index, :new, :create]
  load_and_authorize_resource through: :exhibit, only: [:index, :new, :create]

  load_and_authorize_resource only: [:edit, :update, :destroy]

  def new

  end

  def edit
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

  def custom_field_params
    params.require(:custom_field).permit(configuration: [:label, :short_description])
  end
end