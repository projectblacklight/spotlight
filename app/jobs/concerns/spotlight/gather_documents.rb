# frozen_string_literal: true

module Spotlight
  # Gather documents by a given query that can be used in a job
  # Will also increment job tracking total
  module GatherDocuments
    extend ActiveSupport::Concern

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
