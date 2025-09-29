# frozen_string_literal: true

module Spotlight
  # ...
  module SearchHelper
    # @return [Hash] a hash of context information to pass through to the search service
    def search_service_context
      return {} unless respond_to?(:current_ability)

      { current_ability: }
    end
  end
end
