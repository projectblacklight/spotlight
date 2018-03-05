module Spotlight
  # :nodoc:
  class ExhibitIndexingChannel < ApplicationCable::Channel
    def subscribed
      exhibit = Spotlight::Exhibit.find(params[:id])
      stream_for exhibit
    end

    def update
      exhibit = Spotlight::Exhibit.find(params[:id])
      entry = exhibit.reindexing_log_entries.where.not(job_status: 'unstarted').first

      self.class.broadcast_to(exhibit, ReindexProgress.new(entry)) if entry
    end
  end
end
