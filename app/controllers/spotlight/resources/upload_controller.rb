# frozen_string_literal: true

module Spotlight
  module Resources
    ##
    # Creating new exhibit items from single-item entry forms
    # or batch CSV upload
    class UploadController < Spotlight::ApplicationController
      helper :all

      before_action :authenticate_user!
      before_action :set_tab, only: %i[create]

      load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
      before_action :build_resource

      load_and_authorize_resource class: 'Spotlight::Resources::Upload', through_association: 'exhibit.resources', instance_name: 'resource'

      def create
        if @resource.save_and_index
          flash[:notice] = t('spotlight.resources.upload.success')
          return redirect_to new_exhibit_resource_path(@resource.exhibit, tab: :upload) if params['add-and-continue']
        else
          flash[:error] = t('spotlight.resources.upload.error')
        end

        redirect_to admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
      end

      private

      def set_tab
        @tab = params[:tab] || 'external_resources_form'
      end

      def build_resource
        @resource ||= begin
          resource = Spotlight::Resources::Upload.new exhibit: current_exhibit
          resource.attributes = resource_params
          resource.build_upload(image: params[:resources_upload][:url]) if params[:resources_upload][:url]

          resource
        end
      end

      def resource_params
        params.require(:resources_upload).permit(data: data_param_keys)
      end

      def data_param_keys
        Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) +
          current_exhibit.custom_fields.as_strong_params
      end
    end
  end
end
