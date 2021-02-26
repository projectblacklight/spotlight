# frozen_string_literal: true

module Spotlight
  ##
  # Locking mechanism for page-level locks
  class JobTrackersController < Spotlight::ApplicationController
    load_and_authorize_resource :exhibit
    load_and_authorize_resource through: :exhibit

    # GET /:exhibit_id/job_trackers/1
    def show
      add_breadcrumb t(:'spotlight.exhibits.breadcrumb', title: @exhibit.title), @exhibit
      add_breadcrumb t(:'spotlight.curation.sidebar.dashboard'), exhibit_dashboard_path(@exhibit)
      add_breadcrumb t(:'spotlight.configuration.sidebar.job_trackers'), [@job_tracker.on, @job_tracker]
    end
  end
end
