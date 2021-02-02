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

      progress.total = resource_list(job.arguments.first, **pagination).sum(&:estimated_size)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def perform(exhibit_or_resources, per: nil, page: nil, last: false, **)
      job_tracker.update(status: 'in_progress')

      errors = 0

      error_handler = lambda do |pipeline, _error_context, exception, _data|
        job_tracker.append_log_entry(type: :error, message: exception.to_s, resource_id: pipeline.source&.id)
        errors += 1
      end

      resource_list(exhibit_or_resources, per: per, page: page, last: last).each do |resource|
        resource.reindex(touch: false, commit: false, job_tracker: job_tracker, additional_data: job_data, on_error: error_handler) do |*|
          progress&.increment
        end
      rescue StandardError => e
        error_handler.call(Struct.new(:source).new(resource), self, e, nil)
      end

      exhibit&.touch # rubocop:disable Rails/SkipsModelValidations

      job_tracker.append_log_entry(type: :info, message: "#{progress.progress} of #{progress.total} (#{errors} errors)")
      job_tracker.update(status: errors.zero? ? 'completed' : 'failed', data: { progress: progress.progress, total: progress.total })
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

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
      exhibit
    end

    def exhibit
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
