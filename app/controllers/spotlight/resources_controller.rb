module Spotlight
  class ResourcesController < ApplicationController
    before_filter :authenticate_user!, except: [:show]

    load_resource :exhibit, class: Spotlight::Exhibit
    before_filter :build_resource, only: :create

    load_and_authorize_resource through: :exhibit

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

    def build_resource
      @resource ||= @exhibit.resources.build(resource_params).becomes_provider
    end
  end
end
