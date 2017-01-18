module Spotlight
  ##
  # Reindex the given resources or exhibits
  class ReindexJob < ActiveJob::Base
    queue_as :default

    before_enqueue do |job|
      resource_list(job.arguments.first).each(&:waiting!)
    end

    around_perform do |job, block|
      job_log_entry = log_entry(job)
      job_log_entry.in_progress! if job_log_entry

      begin
        block.call
      rescue
        job_log_entry.failed! if job_log_entry
        raise
      end

      job_log_entry.succeeded! if job_log_entry
    end

    def perform(exhibit_or_resources, _log_entry = nil)
      resource_list(exhibit_or_resources).each(&:reindex)
    end

    private

    def resource_list(exhibit_or_resources)
      if exhibit_or_resources.is_a?(Spotlight::Exhibit)
        exhibit_or_resources.resources.find_each
      elsif exhibit_or_resources.is_a?(Enumerable)
        exhibit_or_resources
      else
        Array(exhibit_or_resources)
      end
    end

    def log_entry(job)
      job.arguments.second if job.arguments.second.is_a?(Spotlight::ReindexingLogEntry)
    end
  end
end
