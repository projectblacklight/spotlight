# frozen_string_literal: true

module Spotlight
  ###
  class ChangeVisibilityJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking
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

    # rubocop:disable Metrics/MethodLength
    def each_document(solr_params, exhibit, &block)
      return to_enum(:each_document, solr_params, exhibit) unless block_given?

      cursor_mark = nil
      next_cursor_mark = '*'

      until next_cursor_mark == cursor_mark || next_cursor_mark.nil?
        cursor_mark = next_cursor_mark
        response = exhibit.blacklight_config.repository.search(
          solr_params.merge(
            'rows' => Spotlight::Engine.config.bulk_actions_batch_size,
            'cursorMark' => cursor_mark,
            'sort' => "#{exhibit.blacklight_config.document_model.unique_key} asc"
          )
        )
        progress.total = response.total
        response.documents.each do |document|
          block.call(document)
        end

        next_cursor_mark = response['nextCursorMark']
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
