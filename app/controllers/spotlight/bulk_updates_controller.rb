# frozen_string_literal: true

require 'csv'

module Spotlight
  ##
  # Controller enabling bulk functionality for items defined in a spreadsheet.
  class BulkUpdatesController < Spotlight::ApplicationController
    before_action :authenticate_user!
    before_action :check_authorization

    def edit; end

    def download_template
      send_data csv_template, type: 'text/csv', filename: 'bulk-update-template.csv'
    end

    def update
      bulk_update = Spotlight::BulkUpdate.new(exhibit: current_exhibit, file: file_params)
      if bulk_update.save
        ProcessBulkUpdatesCsvJob.perform_later(current_exhibit, bulk_update)
        redirect_back fallback_location: spotlight.edit_exhibit_bulk_updates_path(current_exhibit), notice: t(:'spotlight.bulk_updates.update.submitted')
      else
        redirect_back fallback_location: spotlight.edit_exhibit_bulk_updates_path(current_exhibit), alert: t(:'spotlight.bulk_updates.update.error')
      end
    end

    private

    def csv_template
      boolean = ActiveModel::Type::Boolean.new
      Spotlight::BulkUpdatesCsvTemplateService.new(exhibit: current_exhibit).template(
        view_context: view_context,
        title: boolean.cast(reference_field_params[:item_title]),
        tags: boolean.cast(updatable_field_params[:tags]),
        visibility: boolean.cast(updatable_field_params[:visibility])
      )
    end

    def reference_field_params
      params.require(:reference_fields).permit(:item_title)
    end

    def updatable_field_params
      params.require(:updatable_fields).permit(:visibility, :tags)
    end

    def file_params
      params.require(:file)
    end

    def check_authorization
      authorize! :bulk_update, current_exhibit
    end
  end
end
