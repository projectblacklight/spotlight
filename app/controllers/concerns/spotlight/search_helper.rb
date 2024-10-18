# frozen_string_literal: true

module Spotlight
  # ...
  module SearchHelper
    def search_service(user_params = respond_to?(:search_state, true) ? search_state.to_h : {})
      klass = respond_to?(:search_service_class) ? search_service_class : Blacklight::SearchService

      klass.new(config: blacklight_config, user_params:, **search_service_context)
    end

    # @return [Hash] a hash of context information to pass through to the search service
    def search_service_context
      return {} unless respond_to?(:current_ability)

      { current_ability: }
    end
  end
end
