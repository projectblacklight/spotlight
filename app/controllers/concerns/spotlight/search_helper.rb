module Spotlight
  # ...
  module SearchHelper
    def search_service
      search_service_class.new(config: blacklight_config, user_params: (respond_to?(:search_state, true) ? search_state.to_h : {}), **search_service_context)
    end

    def search_service_class
      if defined?(super)
        super
      else
        Blacklight::SearchService
      end
    end

    # @return [Hash] a hash of context information to pass through to the search service
    def search_service_context
      return {} unless respond_to?(:current_ability)

      { current_ability: current_ability }
    end
  end
end
