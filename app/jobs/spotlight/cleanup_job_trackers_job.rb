# frozen_string_literal: true

module Spotlight
  ###
  # Deletes completed job trackers that were last updated before
  # Spotlight::Engine.config.reindex_progress_window. Spotlight does not
  # enqueue this job itself; applications should schedule it to run
  # periodically (see the README).
  ###
  class CleanupJobTrackersJob < Spotlight::ApplicationJob
    def perform
      Spotlight::JobTracker.where(status: 'completed', updated_at: Time.zone.at(0)...Spotlight::Engine.config.reindex_progress_window.ago).delete_all
    end
  end
end
