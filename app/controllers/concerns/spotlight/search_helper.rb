# frozen_string_literal: true

module Spotlight
  # ...
  module SearchHelper
    # @param [Blacklight::SearchState] state the search state to use. Defaults to the existing
    #   search state available in context (controller or model), or an empty one otherwise.
    # @return [Object] An instance of the configured search service
    def search_service(state = respond_to?(:search_state, true) ? search_state : Blacklight::SearchState.new({}, blacklight_config))
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
