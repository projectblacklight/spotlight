# frozen_string_literal: true

module Spotlight
  ##
  # BackgroundJobProgress is a class that models the progress of a list of resources
  class BackgroundJobProgress
    attr_reader :exhibit, :job_class

    delegate :updated_at, to: :most_relevant_job_tracker

    def initialize(exhibit, job_class:)
      @exhibit = exhibit
      @job_class = job_class
    end

    def as_json(*)
      {
        recently_in_progress: recently_in_progress?,
        started_at: localized_start_time,
        finished_at: localized_finish_time,
        updated_at: localized_updated_time,
        total: [total, completed].max,
        completed:,
        finished: finished?,
        errored: errored?
      }
    end

    private

    def job_trackers
      @job_trackers ||= exhibit.job_trackers.where(job_class: job_class.to_s).recent
    end

    def most_relevant_job_tracker
      return @most_relevant_job_tracker if @most_relevant_job_tracker

      @most_relevant_job_tracker ||= job_trackers.in_progress.first || job_trackers.completed.first || job_trackers.first || Spotlight::JobTracker.new
    end

    def recently_in_progress?
      return false unless most_relevant_job_tracker.persisted?
      return true if most_relevant_job_tracker.in_progress?

      finished? && most_relevant_job_tracker.updated_at >= Spotlight::Engine.config.reindex_progress_window.ago
    end

    def started_at
      most_relevant_job_tracker.created_at
    end

    def finished?
      most_relevant_job_tracker.completed? || (errored? && most_relevant_job_tracker.job_trackers.none?(&:in_progress?))
    end

    def finished_at
      return unless finished?

      most_relevant_job_tracker.updated_at
    end

    def total
      return most_relevant_job_tracker.total if finished? || most_relevant_job_tracker.job_trackers.none?

      most_relevant_job_tracker.job_trackers.sum(&:total)
    end

    def completed
      return most_relevant_job_tracker.progress if finished? || most_relevant_job_tracker.job_trackers.none?

      most_relevant_job_tracker.job_trackers.sum(&:progress)
    end

    def errored?
      most_relevant_job_tracker.failed?
    end

    def localized_start_time
      return unless started_at

      I18n.l(started_at, format: :long)
    end

    def localized_finish_time
      return unless finished_at

      I18n.l(finished_at, format: :long)
    end

    def localized_updated_time
      return unless updated_at

      I18n.l(updated_at, format: :long)
    end
  end
end
