module Spotlight
  ##
  # a log entry representing an attempt to reindex some number of records in an exhibit
  class ReindexingLogEntry < ActiveRecord::Base
    enum job_status: { unstarted: 0, in_progress: 1, succeeded: 2, failed: 3 }

    belongs_to :exhibit, class_name: 'Spotlight::Exhibit'
    belongs_to :user, class_name: '::User'

    # null start times sort to the top, to more easily surface pending reindexing
    default_scope { order('start_time IS NOT NULL, start_time DESC') }
    scope :recent, -> { limit(5) }

    def duration
      end_time - start_time if end_time
    end
  end
end
