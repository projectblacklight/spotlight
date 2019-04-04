# frozen_string_literal: true

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
        csv = CSV.parse(csv_io_param, headers: true, return_headers: false).map(&:to_hash)
        Spotlight::AddUploadsFromCSV.perform_later(csv, current_exhibit, current_user)
        flash[:notice] = t('spotlight.resources.upload.csv.success', file_name: csv_io_name)
        redirect_back(fallback_location: spotlight.exhibit_resources_path(current_exhibit))
      end

      def template
        render plain: CSV.generate { |csv| csv << data_param_keys.unshift(:url) }, content_type: 'text/csv'
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

      # Gets an IO-like object for the CSV parser to use.
      # @return IO
      def csv_io_param
        file_or_io = csv_params[:url]
        io = if file_or_io.respond_to?(:to_io)
               file_or_io.to_io
             else
               file_or_io
             end

        io.set_encoding('utf-8')
      end

      def csv_io_name
        file_or_io = csv_params[:url]

        if file_or_io.respond_to? :original_filename
          file_or_io.original_filename
        else
          t('spotlight.resources.upload.csv.anonymous_file')
        end
      end
    end
  end
end
