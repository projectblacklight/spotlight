# frozen_string_literal: true

require 'csv'

module Spotlight
  # A service to generate a CSV template suitable for re-uploading for bulk updates
  class BulkUpdatesCsvTemplateService
    attr_reader :exhibit

    def initialize(exhibit:)
      @exhibit = exhibit
    end

    def template(view_context:, title: true, tags: true, visibility: true)
      return to_enum(:template, view_context: view_context, title: title, tags: tags, visibility: visibility) unless block_given?

      yield ::CSV.generate_line(csv_headers(title: title, tags: tags, visibility: visibility))
      each_document do |document|
        sidecar = document.sidecar(exhibit)
        yield ::CSV.generate_line([
          document.id,
          (title_column(view_context, document) if title),
          (visibility_column(sidecar) if visibility),
          (tags_column(sidecar) if tags)
        ].flatten.compact)
      end
    end

    private

    def title_column(view_context, document)
      CGI.unescapeHTML(view_context.document_presenter(document).heading)
    end

    def visibility_column(sidecar)
      sidecar.public ? 'TRUE' : ' '
    end

    def tags_column(sidecar)
      exhibit_tags.map do |tag|
        sidecar.all_tags_list.include?(tag) ? 'TRUE' : ' '
      end
    end

    def exhibit_tags
      @exhibit_tags ||= exhibit.owned_tags.map(&:name)
    end

    def csv_headers(title:, tags:, visibility:)
      headers = [bulk_updates_config.csv_id]
      headers.append(bulk_updates_config.csv_title) if title
      headers.append(bulk_updates_config.csv_visibility) if visibility
      if tags
        exhibit_tags.each do |tag|
          headers.append(format(bulk_updates_config.csv_tags, tag))
        end
      end
      headers
    end

    def bulk_updates_config
      Spotlight::Engine.config.bulk_updates
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def each_document(&block)
      return to_enum(:each_document) unless block_given?

      cursor_mark = nil
      next_cursor_mark = '*'

      solr_params = exhibit&.exhibit_search_builder&.to_h || {}

      until next_cursor_mark == cursor_mark || next_cursor_mark.nil?
        cursor_mark = next_cursor_mark
        response = exhibit.blacklight_config.repository.search(
          solr_params.merge(
            'q' => '*',
            'rows' => Spotlight::Engine.config.bulk_actions_batch_size,
            'cursorMark' => cursor_mark,
            'sort' => "#{exhibit.blacklight_config.document_model.unique_key} asc"
          )
        )
        response.documents.each do |document|
          block.call(document)
        end

        next_cursor_mark = response['nextCursorMark']
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
