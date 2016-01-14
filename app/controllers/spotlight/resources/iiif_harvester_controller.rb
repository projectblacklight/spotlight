module Spotlight
  module Resources
    class IiifHarvesterController < Spotlight::ApplicationController
      before_action :authenticate_user!

      load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
      before_action :build_resource

      def create
        if @resource.save_and_index
          redirect_to spotlight.admin_exhibit_catalog_index_path(current_exhibit, sort: :timestamp)
        else
          flash[:error] = @resource.errors.values.join(', ') if @resource.errors.present?
          redirect_to spotlight.new_exhibit_resource_path(current_exhibit)
        end
      end

      private

      def resource_params
        params.require(:resources_iiif_harvester).permit(:url)
      end

      def build_resource
        @resource ||= Spotlight::Resources::IiifHarvester.create(
          url: resource_params[:url],
          exhibit: current_exhibit
        )
      end
    end
  end
end
