# frozen_string_literal: true

module Spotlight
  # ...
  module SearchHelper
    # @param [Hash] user_params the query parameters used to reconstitute the search state
    #          from saved searches. If not provided, will use the search_state from the view context
    #          or an empty hash if that is not available.
    # @return [Object] An instance of the configured search service
    def search_service(user_params = respond_to?(:search_state, true) ? search_state.to_h : {})
      state = Blacklight::SearchState.new(user_params, blacklight_config)
      klass = respond_to?(:search_service_class) ? search_service_class : Blacklight::SearchService

      klass.new(config: blacklight_config, search_state: state, **search_service_context)
    end

    # @return [Hash] a hash of context information to pass through to the search service
    def search_service_context
      return {} unless respond_to?(:current_ability)

      { current_ability: }
    end
  end
end
