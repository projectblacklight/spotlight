# frozen_string_literal: true

module Spotlight
  ###
  class ChangeVisibilityJob < Spotlight::ApplicationJob
    def perform(solr_params:, exhibit:, visibility:, **)
      each_document(solr_params, exhibit) do |document|
        case visibility
        when 'public'
          document.make_public!(exhibit)
        when 'private'
          document.make_private!(exhibit)
        end
        document.reindex(update_params: {})
      end
      exhibit.blacklight_config.repository.connection.commit
    end

    # rubocop:disable Metrics/MethodLength
    def each_document(solr_params, exhibit, &block)
      return to_enum(:each_document, solr_params, exhibit) unless block_given?

      cursor_mark = '*'
      response = {}

      while response['nextCursorMark'] == cursor_mark
        response = exhibit.blacklight_config.repository.search(
          solr_params.merge(
            'rows' => Spotlight::Engine.config.bulk_actions_batch_size,
            'cursorMark' => cursor_mark,
            'sort' => "#{exhibit.blacklight_config.document_model.unique_key} asc"
          )
        )

        response.documents.each do |document|
          block.call(document)
        end

        cursor_mark = response['nextCursorMark']
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
