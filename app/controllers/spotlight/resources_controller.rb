module Spotlight
  class ResourcesController < ApplicationController
    before_filter :authenticate_user!, except: [:show]

    load_resource :exhibit, class: Spotlight::Exhibit

    def index
      render json: @resources
    end

    def new

    end

    def create
      @resource.attributes = resource_params

      if @resource.save
        redirect_to admin_exhibit_catalog_index_path(@resource.exhibit)
      else
        render action: 'new'
      end
    end

    protected
    def resource_params
      params.require(:resource).permit(:url)
    end
  end
end