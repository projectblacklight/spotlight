# frozen_string_literal: true

module Spotlight
  ###
  # Calls the #set_default_thumbnail method
  # on the object passed in and calls save
  ###
  class CleanupJobTrackersJob < Spotlight::ApplicationJob
    def perform
      Spotlight::JobTracker.where(status: 'completed', updated_at: Time.zone.at(0)...Spotlight::Engine.config.reindex_progress_window.minutes.ago).delete_all
    end
  end
end
