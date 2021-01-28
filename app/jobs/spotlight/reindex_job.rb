# frozen_string_literal: true

module Spotlight
  ##
  # Reindex the given resources or exhibits
  class ReindexJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking
    include Spotlight::LimitConcurrency

    before_perform do |job|
      pagination = job.arguments.last.slice(:per, :page, :last) if job.arguments.last.is_a? Hash
      pagination ||= {}

      items_reindexed_estimate = resource_list(job.arguments.first, **pagination).sum do |resource|
        resource.document_builder.documents_to_index.size
      end

      progress.total = items_reindexed_estimate
    end

    def perform(exhibit_or_resources, *args, per: nil, page: nil, last: false, **)
      job_tracker.update(status: 'in_progress')

      errors = 0

      resource_list(exhibit_or_resources, per: per, page: page, last: last).each do |resource|
        service = resource.reindex(commit: false, job_tracker: job_tracker, additional_data: job_data) do |batch|
          progress&.increment(batch.length)
        end

        if service&.errors.to_i.positive?
          errors += service&.errors.to_i
          job_tracker.append_log_entry(type: :error, resource_id: resource.id)
        end
      rescue StandardError => e
        Rails.logger.error(e)
        errors += 1
        job_tracker.append_log_entry(type: :error, message: e.to_s, resource_id: resource.id)
      end

      job_tracker.append_log_entry(type: :info, message: "#{progress.progress} of #{progress.total} (#{errors} errors)")
      job_tracker.update(status: errors.zero? ? 'completed' : 'failed', data: { progress: progress.progress, total: progress.total })
    end

    private

    def job_data
      return unless job_tracker

      { Spotlight::Engine.config.job_tracker_id_field => job_tracker.top_level_job_tracker.job_id }
    end

    def resource_list(exhibit_or_resources, per: nil, page: nil, last: false)
      if exhibit_or_resources.is_a?(Spotlight::Exhibit)
        resources = exhibit_or_resources.resources
        if per
          resources = resources.offset((page - 1) * per)
          resources = resources.limit(per) unless last
        end
        resources.find_each
      else
        Array(exhibit_or_resources)
      end
    end

    def job_tracking_resource
      exhibit_or_resources = arguments.first

      case exhibit_or_resources
      when Spotlight::Exhibit
        exhibit_or_resources
      when Spotlight::Resource
        exhibit_or_resources.exhibit
      end
    end
  end
end
