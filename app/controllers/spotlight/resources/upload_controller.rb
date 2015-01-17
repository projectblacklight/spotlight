module Spotlight::Resources
  class UploadController < ApplicationController
    helper :all

    before_filter :authenticate_user!

    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    before_filter :build_resource, only: [:new, :create]

    load_and_authorize_resource class: 'Spotlight::Resources::Upload', through_association: "exhibit.resources", instance_name: 'resource'

    def create
      @resource.attributes = resource_params

      if @resource.save
        flash[:notice] = t('spotlight.resources.upload.success')
        if params["add-and-continue"]
          redirect_to new_exhibit_resources_upload_path(@resource.exhibit)
        else
          redirect_to admin_exhibit_catalog_index_path(@resource.exhibit)
        end
      else
        flash[:error] = t('spotlight.resources.upload.error')
        redirect_to admin_exhibit_catalog_index_path(@resorce.exhibit)
      end
    end

    private
    def build_resource
      @resource ||= Spotlight::Resources::Upload.new exhibit: current_exhibit
    end

    def resource_params
      params.require(:resources_upload).permit(:url, data: data_param_keys)
    end

    def data_param_keys
      Spotlight::Resources::Upload.fields(current_exhibit).keys + current_exhibit.custom_fields.map(&:field)
    end

  end
end
