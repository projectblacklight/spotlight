module Spotlight
  ##
  # ReindexProgress is a class that models the progress of reindexing a list of resources
  class ReindexProgress
    def initialize(resource_list)
      @resources = if resource_list.present?
                     resource_list
                   else
                     null_resources
                   end
    end

    def in_progress?
      return unless finished
      any_waiting? || finished > Spotlight::Engine.config.reindex_progress_window.minutes.ago
    end

    def started
      @started ||= resources.first.indexed_at
    end

    def finished
      @finished ||= completed_resources.last.updated_at
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
        in_progress: in_progress?,
        started: localized_start_time,
        total: total,
        completed: completed,
        updated_at: localized_finish_time,
        errored: errored?
      }
    end

    private

    attr_reader :resources

    def any_waiting?
      resources.any?(&:waiting?)
    end

    def localized_start_time
      return unless started
      I18n.l(started, format: :short)
    end

    def localized_finish_time
      return unless finished
      I18n.l(finished, format: :short)
    end

    def completed_resources
      if resources.try(:completed).present?
        resources.completed
      else
        null_resources
      end
    end

    def null_resources
      [NullResource.new]
    end

    ##
    # A NullObject for use in the absense of resources
    class NullResource
      def updated_at
        nil
      end

      def indexed_at
        nil
      end

      def last_indexed_estimate
        0
      end

      def last_indexed_count
        0
      end

      def waiting?
        false
      end

      def errored?
        false
      end
    end
  end
end
