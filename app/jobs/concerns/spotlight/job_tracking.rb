# frozen_string_literal: true

module Spotlight
  # Job status tracking
  module JobTracking
    extend ActiveSupport::Concern
    include ActiveJob::Status

    class_methods do
      # @param resource [Proc] receives the job and returns the resource connect to the job tracking status
      # @param reports_on [Proc] optional, receives the job and returns a Spotlight::JobTracker to "roll up" statuses to
      # @param user [Proc] optional, receives the job and returns the User that initiated the job
      def with_job_tracking(
        resource:,
        reports_on: ->(job) { job.arguments.last[:reports_on] if job.arguments.last.is_a?(Hash) },
        user: ->(job) { job.arguments.last[:user] if job.arguments.last.is_a?(Hash) }
      )
        around_perform do |job, block|
          resource_object = resource&.call(job)

          job.initialize_job_tracker!(
            resource: resource_object,
            on: reports_on&.call(job) || resource_object,
            user: user&.call(job)
          )

          block.call
        ensure
          job.finalize_job_tracker!
        end
      end
    end

    def mark_job_as_failed!
      @failed = true
    end

    def job_tracker
      @job_tracker ||= find_or_initialize_job_tracker
    end

    def initialize_job_tracker!(**params)
      job_tracker.update(params.merge(status: 'in_progress').compact)
    end

    def finalize_job_tracker!
      return unless job_tracker.status == 'in_progress' || job_tracker.status == 'enqueued'

      job_tracker.update(
        status: @failed ? 'failed' : 'completed',
        data: { progress: progress.progress, total: progress.total }
      )
    end

    private

    def find_or_initialize_job_tracker
      JobTracker.find_or_create_by(job_id: job_id) do |tracker|
        tracker.job_class = self.class.name
        tracker.status = 'enqueued'
      end
    end
  end
end
