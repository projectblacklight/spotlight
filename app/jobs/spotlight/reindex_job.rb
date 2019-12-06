# frozen_string_literal: true

module Spotlight
  ##
  # Reindex the given resources or exhibits
  class ReindexJob < ActiveJob::Base
    queue_as :default

    # The validity checker is a seam for implementations to expire unnecessary
    # indexing tasks if it becomes redundant while waiting in the job queue.
    class_attribute :validity_checker, default: Spotlight::ValidityChecker.new
    self.validity_checker ||= Spotlight::ValidityChecker.new if Rails.version < '5.2'

    before_perform do |job|
      job_log_entry = log_entry(job)
      next unless job_log_entry

      items_reindexed_estimate = resource_list(job.arguments.first).sum do |resource|
        resource.document_builder.documents_to_index.size
      end
      job_log_entry.update(items_reindexed_estimate: items_reindexed_estimate)
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

    def self.perform_later(exhibit_or_resources, log_entry = nil)
      validity_token = validity_checker.mint(exhibit_or_resources)

      super(exhibit_or_resources, log_entry, validity_token)
    end

    def perform(exhibit_or_resources, log_entry = nil, validity_token = nil)
      return unless still_valid?(exhibit_or_resources, validity_token)

      resource_list(exhibit_or_resources).each do |resource|
        resource.reindex(log_entry)
      end
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

    def still_valid?(exhibit_or_resources, validity_token)
      return true unless validity_token

      validity_checker.check exhibit_or_resources, validity_token
    end
  end
end
