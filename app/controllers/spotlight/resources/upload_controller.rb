module Spotlight
  module Resources
    ##
    # Creating new exhibit items from single-item entry forms
    # or batch CSV upload
    class UploadController < Spotlight::ApplicationController
      helper :all

      before_action :authenticate_user!

      load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
      before_action :build_resource

      load_and_authorize_resource class: 'Spotlight::Resources::Upload', through_association: 'exhibit.resources', instance_name: 'resource'

      # rubocop:disable Metrics/MethodLength
      def create
        check_versions
        @resource.attributes = resource_params

        if @resource.save_and_index
          flash[:notice] = t('spotlight.resources.upload.success')
          if params['add-and-continue']
            redirect_to new_exhibit_resource_path(@resource.exhibit, anchor: :new_resources_upload)
          else
            redirect_to admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
          end
        else
          flash[:error] = t('spotlight.resources.upload.error')
          redirect_to admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def check_versions
        return if params['resources_upload']['thumb'].nil?
        @resource.url.versions.delete(:thumb)
        @resource.url.versions.delete(:square)
      end

      def build_resource
        @resource ||= Spotlight::Resources::Upload.new exhibit: current_exhibit
      end

      def resource_params
        params.require(:resources_upload).permit(:url, :thumb, data: data_param_keys)
      end

      def data_param_keys
        Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) + current_exhibit.custom_fields.map(&:field)
      end
    end
  end
end
