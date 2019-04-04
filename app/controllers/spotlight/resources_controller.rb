# frozen_string_literal: true

module Spotlight
  ##
  # CRUD actions for exhibit resources
  class ResourcesController < Spotlight::ApplicationController
    before_action :authenticate_user!, except: [:show]

    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

    # explicit options support better subclassing
    load_and_authorize_resource through: :exhibit, instance_name: :resource, through_association: :resources

    helper_method :resource_class

    def new
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_path(@exhibit)
      add_breadcrumb t(:'spotlight.resources.new.header'), new_exhibit_resource_path(@exhibit)

      render
    end

    def create
      if @resource.save_and_index
        redirect_to spotlight.admin_exhibit_catalog_path(@resource.exhibit, sort: :timestamp)
      else
        flash[:error] = @resource.errors.full_messages.to_sentence if @resource.errors.present?
        render action: 'new'
      end
    end
    alias update create

    def monitor
      render json: current_exhibit.reindex_progress
    end

    def reindex_all
      @exhibit.reindex_later current_user

      redirect_to admin_exhibit_catalog_path(@exhibit), notice: t(:'spotlight.resources.reindexing_in_progress')
    end

    protected

    def resource_class
      Spotlight::Resource
    end

    def resource_params
      params.require(:resource).tap { |x| x['type'] ||= resource_class.name }
            .permit(:url, :type, *resource_class.stored_attributes[:data], data: params[:resource][:data].try(:keys))
    end
  end
end
