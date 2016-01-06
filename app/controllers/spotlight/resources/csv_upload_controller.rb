require 'csv'

module Spotlight
  module Resources
    ##
    # Creating new exhibit items from single-item entry forms
    # or batch CSV upload
    class CsvUploadController < ApplicationController
      helper :all

      before_action :authenticate_user!

      load_and_authorize_resource :exhibit, class: Spotlight::Exhibit

      def create
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

      def data_param_keys
        Spotlight::Resources::Upload.fields(current_exhibit).map(&:field_name) + current_exhibit.custom_fields.map(&:field)
      end
    end
  end
end
