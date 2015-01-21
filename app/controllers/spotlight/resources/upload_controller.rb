require 'csv'

module Spotlight::Resources
  class UploadController < ApplicationController
    helper :all

    before_filter :authenticate_user!

    load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
    before_filter :build_resource, only: [:new, :create, :template]

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

    def csv_upload
      file = csv_params[:url]
      csv = CSV.parse(file.read, {headers:true, return_headers: false}).map(&:to_hash)
      Spotlight::AddUploadsFromCSV.perform_later(csv, current_exhibit, current_user)
      flash[:notice] = t('spotlight.resources.upload.csv.success', file_name: file.original_filename)
      redirect_to :back
    end

    def template
      render text: CSV.generate { |csv| csv << data_param_keys.unshift(:url) }, content_type: 'text/csv'
    end

    private
    def build_resource
      @resource ||= Spotlight::Resources::Upload.new exhibit: current_exhibit
    end

    def csv_params
      params.require(:resources_csv_upload).permit(:url)
    end

    def resource_params
      params.require(:resources_upload).permit(:url, data: data_param_keys)
    end

    def data_param_keys
      Spotlight::Resources::Upload.fields(current_exhibit).collect(&:solr_field) + current_exhibit.custom_fields.collect(&:field)
    end

  end
end
