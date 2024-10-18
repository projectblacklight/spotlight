# frozen_string_literal: true

module Spotlight
  ###
  class AddTagsJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking
    include Spotlight::GatherDocuments
    with_job_tracking(resource: ->(job) { job.arguments.last[:exhibit] })

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def perform(solr_params:, exhibit:, tags:, **)
      @errors = 0

      each_document(solr_params, exhibit) do |document|
        sidecar = document.sidecar(exhibit)
        all_tags = sidecar.all_tags_list
        all_tags += tags
        exhibit.tag(document.sidecar(exhibit), with: all_tags, on: :tags)
        document.reindex(update_params: {})
        progress&.increment
      rescue StandardError => e
        job_tracker.append_log_entry(type: :error, exhibit:, message: e.to_s)
        @errors += 1
        mark_job_as_failed!
      end
      exhibit.blacklight_config.repository.connection.commit
      job_tracker.append_log_entry(type: :info, exhibit:, message: "#{progress.progress} of #{progress.total} (#{@errors} errors)")
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
