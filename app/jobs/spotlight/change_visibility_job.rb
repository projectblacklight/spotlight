# frozen_string_literal: true

module Spotlight
  ###
  class ChangeVisibilityJob < Spotlight::ApplicationJob
    def perform(solr_params:, exhibit:, visibility:, **)
      documents = retrieve_documents(solr_params, exhibit)
      documents.each do |document|
        case visibility
        when 'public'
          document.make_public!(exhibit)
        when 'private'
          document.make_private!(exhibit)
        end
        document.reindex
      end
    end

    # rubocop:disable Metrics/MethodLength
    def retrieve_documents(solr_params, exhibit)
      cursor_mark = '*'
      documents = []
      loop do
        response = exhibit.blacklight_config.repository.search(
          solr_params.merge(
            'rows' => Spotlight::Engine.config.bulk_actions_batch_size,
            'cursorMark' => cursor_mark,
            'sort' => "#{exhibit.blacklight_config.document_model.unique_key} asc"
          )
        )
        documents.concat response.documents
        break if response['nextCursorMark'] == cursor_mark

        cursor_mark = response['nextCursorMark']
      end
      documents
    end
    # rubocop:enable Metrics/MethodLength
  end
end
