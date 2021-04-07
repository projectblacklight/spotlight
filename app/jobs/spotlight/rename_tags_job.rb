# frozen_string_literal: true

module Spotlight
  ###
  class RenameTagsJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking

    with_job_tracking(resource: ->(job) { job.arguments.first })

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def perform(exhibit, tag, to: nil, **)
      @errors = 0

      tag.taggings.owned_by(exhibit).find_each do |tagging|
        sidecar = tagging.taggable
        all_tags = sidecar.all_tags_list
        all_tags -= [tag.name]
        all_tags += [to] unless to.nil?

        exhibit.tag(sidecar, with: all_tags, on: :tags)
        sidecar.document.reindex(update_params: {})
      rescue StandardError => e
        job_tracker.append_log_entry(type: :error, exhibit: exhibit, message: e.to_s)
        @errors += 1
        mark_job_as_failed!
      end

      exhibit.blacklight_config.repository.connection.commit
      job_tracker.append_log_entry(type: :info, exhibit: exhibit, message: "#{progress.progress} of #{progress.total} (#{@errors} errors)")
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
