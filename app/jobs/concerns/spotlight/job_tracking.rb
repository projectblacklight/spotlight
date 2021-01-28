# frozen_string_literal: true

module Spotlight
  # Job status tracking
  module JobTracking
    extend ActiveSupport::Concern
    include ActiveJob::Status

    def self.with_job_tracking
      before_perform :find_or_initialize_job_tracker
      after_perform :finalize_job_tracker
    end

    def job_tracker
      @job_tracker ||= find_or_initialize_job_tracker
    end

    private

    def find_or_initialize_job_tracker
      JobTracker.find_or_create_by(job_id: job_id) do |tracker|
        tracker.job_class = self.class.name
        tracker.status = 'enqueued'
        update_job_tracker_properties(tracker)
      end
    end

    def finalize_job_tracker
      job_tracker.update(status: 'completed') if job_tracker.status == 'enqueued'
    end

    def update_job_tracker_properties(tracker)
      tracker.resource = job_tracking_resource
      tracker.on = reports_on_resource || tracker.resource

      tracker.user = arguments.last[:user] if arguments.last.is_a?(Hash)
    end

    def job_tracking_resource
      arguments.first
    end

    def reports_on_resource
      arguments.last[:reports_on] if arguments.last.is_a?(Hash)
    end
  end
end
