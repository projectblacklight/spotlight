# frozen_string_literal: true

module Spotlight
  # Override Blacklight::SearchState to use exhibit-specific routes for documents
  class SearchState < SimpleDelegator
    attr_reader :current_exhibit

    def initialize(search_state, current_exhibit)
      super(search_state)
      @current_exhibit = current_exhibit
    end

    def url_for_document(document, options = {})
      return super unless current_exhibit

      [controller.spotlight, current_exhibit, document]
    end
  end
end
