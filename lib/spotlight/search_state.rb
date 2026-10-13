# frozen_string_literal: true

module Spotlight
  # Override Blacklight::SearchState to use exhibit-specific routes for documents.
  #
  # This must remain the app's search_state_class (set in Spotlight::Controller) for
  # url_for_document to add exhibit context to document routes.
  class SearchState < Blacklight::SearchState
    def url_for_document(document, options = {})
      return super unless controller.respond_to?(:current_exhibit) && controller.current_exhibit

      [controller.spotlight, controller.current_exhibit, document]
    end
  end
end
