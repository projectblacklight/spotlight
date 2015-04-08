# encoding: utf-8
require 'csv'

module Spotlight
  module Resources
    ##
    # Creating new exhibit items from single-item entry forms
    # or batch CSV upload
    class UploadController < ApplicationController
      helper :all

      before_action :authenticate_user!

      load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
      before_action :build_resource, only: [:new, :create, :template]

      load_and_authorize_resource class: 'Spotlight::Resources::Upload', through_association: 'exhibit.resources', instance_name: 'resource'
      def new
        add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), exhibit_root_path(@exhibit)
        add_breadcrumb t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit)
        add_breadcrumb t(:'spotlight.curation.sidebar.items'), admin_exhibit_catalog_index_path(@exhibit)
        add_breadcrumb t(:'spotlight.resources.upload.new.header'), new_exhibit_resources_upload_path(@exhibit)
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def create
        @resource.attributes = resource_params

        if @resource.save_and_commit
          flash[:notice] = t('spotlight.resources.upload.success')
          if params['add-and-continue']
            redirect_to new_exhibit_resources_upload_path(@resource.exhibit)
          else
            redirect_to admin_exhibit_catalog_index_path(@resource.exhibit, sort: :timestamp)
          end
        else
          flash[:error] = t('spotlight.resources.upload.error')
          redirect_to admin_exhibit_catalog_index_path(@resource.exhibit, sort: :timestamp)
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def csv_upload
        file = csv_params[:url]
        csv = CSV.parse(file.read, headers: true, return_headers: false, encoding: 'utf-8').map(&:to_hash)
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
        Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) + current_exhibit.custom_fields.map(&:field)
      end
    end
  end
end
