# frozen_string_literal: true

module Spotlight
  # ...
  module SearchHelper
    # @param [Blacklight::SearchState] state the search state to use. If not provided, builds one
    #   from the search_state available in context (controller or model), or an empty state if
    #   neither is available. Note: Spotlight::SearchState cannot be passed directly because it is
    #   a SimpleDelegator (not a Blacklight::SearchState subclass), and Blacklight's
    #   SearchBuilder#with performs an is_a? check.
    # @return [Object] An instance of the configured search service
    def search_service(state = Blacklight::SearchState.new(respond_to?(:search_state, true) ? search_state.to_h : {}, blacklight_config))
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
