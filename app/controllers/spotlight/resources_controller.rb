module Spotlight
  ##
  # CRUD actions for exhibit resources
  class ResourcesController < Spotlight::ApplicationController
    before_action :authenticate_user!, except: [:show]

    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    before_action :build_resource, only: [:create]

    load_and_authorize_resource through: :exhibit

    def new
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_index_path(@exhibit)
      add_breadcrumb t(:'spotlight.resources.new.header'), new_exhibit_resource_path(@exhibit)

      render
    end

    def create
      if @resource.save_and_index
        redirect_to admin_exhibit_catalog_index_path(@resource.exhibit, sort: :timestamp)
      else
        render action: 'new'
      end
    end

    def monitor
      render json: current_exhibit.reindex_progress
    end

    def reindex_all
      @exhibit.reindex_later

      redirect_to admin_exhibit_catalog_index_path(@exhibit), notice: t(:'spotlight.resources.reindexing_in_progress')
    end

    protected

    def resource_params
      params.require(:resource).permit(:url, data: params[:resource][:data].try(:keys))
    end

    def build_resource
      @resource ||= @exhibit.resources.build(resource_params)
    end
  end
end
