# frozen_string_literal: true

module Spotlight
  ###
  class ChangeVisibilityJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking
    include Spotlight::GatherDocuments
    with_job_tracking(resource: ->(job) { job.arguments.last[:exhibit] })

    # rubocop:disable Metrics/MethodLength
    def perform(solr_params:, exhibit:, visibility:, **)
      @errors = 0

      each_document(solr_params, exhibit) do |document|
        case visibility
        when 'public'
          document.make_public!(exhibit)
        when 'private'
          document.make_private!(exhibit)
        end
        document.reindex(update_params: {})
        progress&.increment
      rescue StandardError => e
        job_tracker.append_log_entry(type: :error, exhibit: exhibit, message: e.to_s)
        @errors += 1
        mark_job_as_failed!
      end
      exhibit.blacklight_config.repository.connection.commit
      job_tracker.append_log_entry(type: :info, exhibit: exhibit, message: "#{progress.progress} of #{progress.total} (#{@errors} errors)")
    end
    # rubocop:enable Metrics/MethodLength
  end
end
