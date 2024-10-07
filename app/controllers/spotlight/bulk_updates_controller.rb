# frozen_string_literal: true

require 'csv'

module Spotlight
  ##
  # Controller enabling bulk functionality for items defined in a spreadsheet.
  class BulkUpdatesController < Spotlight::ApplicationController
    before_action :authenticate_user!
    before_action :check_authorization
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'

    def edit
      add_breadcrumb(t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit)
      add_breadcrumb(t(:'spotlight.curation.sidebar.header'), exhibit_dashboard_path(@exhibit))
      add_breadcrumb(t(:'spotlight.pages.index.bulk_updates.header'), edit_exhibit_bulk_updates_path(@exhibit))
    end

    def download_template
      # Set Last-Modified as a work-around for https://github.com/rack/rack/issues/1619
      headers['Last-Modified'] = ''
      headers['Cache-Control'] = 'no-cache'
      headers['Content-Type'] = 'text/csv'
      headers['Content-Disposition'] = "attachment; filename=\"#{current_exhibit.slug}-bulk-update-template.csv\""
      headers.delete('Content-Length')

      self.response_body = csv_template
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

    def monitor
      render json: BackgroundJobProgress.new(current_exhibit, job_class: Spotlight::ProcessBulkUpdatesCsvJob)
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
