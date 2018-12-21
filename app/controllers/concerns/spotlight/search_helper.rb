module Spotlight
  # ...
  module SearchHelper
    def search_service
      Blacklight::SearchService.new(config: blacklight_config, user_params: search_state.to_h)
    end
  end
end
