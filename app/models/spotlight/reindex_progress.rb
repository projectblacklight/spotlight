module Spotlight
  ##
  # ReindexProgress is a class that models the progress of reindexing a list of resources
  class ReindexProgress
    def initialize(resource_list)
      @resources = if resource_list.present?
                     resource_list.order('updated_at')
                   else
                     Spotlight::Resource.none
                   end
    end

    def recently_in_progress?
      any_waiting? || (!!finished_at && finished_at > Spotlight::Engine.config.reindex_progress_window.minutes.ago)
    end

    def started_at
      return unless resources.present?

      @started ||= resources.min_by(&:enqueued_at).enqueued_at
    end

    def updated_at
      @updated ||= resources.maximum(:updated_at) || started_at
    end

    def finished?
      completed_resources.present? && !any_waiting?
    end

    def finished_at
      return unless finished?
      @finished ||= completed_resources.max_by(&:last_indexed_finished).last_indexed_finished
    end

    def total
      @total ||= resources.map(&:last_indexed_estimate).sum
    end

    def completed
      @completed ||= completed_resources.map(&:last_indexed_count).sum
    end

    def errored?
      resources.any?(&:errored?)
    end

    def as_json(*)
      {
        recently_in_progress: recently_in_progress?,
        started_at: localized_start_time,
        finished_at: localized_finish_time,
        updated_at: localized_updated_time,
        total: total,
        completed: completed,
        errored: errored?
      }
    end

    private

    attr_reader :resources

    def any_waiting?
      resources.any?(&:waiting?)
    end

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

    def completed_resources
      resources.completed
    end
  end
end
