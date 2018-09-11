module Spotlight
  ##
  # ReindexProgress is a class that models the progress of reindexing a list of resources
  class ReindexProgress
    attr_reader :current_log_entry

    delegate :updated_at, to: :current_log_entry

    def initialize(current_log_entry)
      @current_log_entry = current_log_entry
    end

    def recently_in_progress?
      return true if current_log_entry.in_progress?

      current_log_entry.end_time.present? && (current_log_entry.end_time > Spotlight::Engine.config.reindex_progress_window.minutes.ago)
    end

    def started_at
      current_log_entry.start_time
    end

    def finished?
      current_log_entry.succeeded? || current_log_entry.failed?
    end

    def finished_at
      current_log_entry.end_time
    end

    def total
      current_log_entry.items_reindexed_estimate
    end

    def completed
      current_log_entry.items_reindexed_count
    end

    def errored?
      current_log_entry.failed?
    end

    def as_json(*)
      {
        recently_in_progress: recently_in_progress?,
        started_at: localized_start_time,
        finished_at: localized_finish_time,
        updated_at: localized_updated_time,
        total: total,
        completed: completed,
        finished: finished?,
        errored: errored?
      }
    end

    private

    def localized_start_time
      return unless started_at

      I18n.l(started_at, format: :short)
    end

    def localized_finish_time
      return unless finished_at

      I18n.l(finished_at, format: :short)
    end

    def localized_updated_time
      return unless updated_at

      I18n.l(updated_at, format: :short)
    end
  end
end
