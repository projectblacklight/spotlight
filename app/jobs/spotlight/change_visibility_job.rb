# frozen_string_literal: true

module Spotlight
  ###
  class ChangeVisibilityJob < Spotlight::ApplicationJob
    include Spotlight::JobTracking

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def perform(solr_params:, exhibit:, visibility:, **)
      job_tracker.update(status: 'in_progress')

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
      end
      exhibit.blacklight_config.repository.connection.commit
      job_tracker.append_log_entry(type: :info, exhibit: exhibit, message: "#{progress.progress} of #{progress.total} (#{@errors} errors)")
    ensure
      job_tracker.update(status: @errors.zero? ? 'completed' : 'failed', data: { progress: progress.progress, total: progress.total })
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def job_tracking_resource
      arguments.last[:exhibit]
    end

    def reports_on_resource
      arguments.last[:exhibit] if arguments.last.is_a?(Hash)
    end

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
