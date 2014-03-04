module Spotlight
  # This module should only be included on controller that load @exhibit
  module Controller
    extend ActiveSupport::Concern
    include Blacklight::Controller
    include Spotlight::Config

    included do
      helper_method :current_exhibit
    end

    # TODO this seems like it needs to be refactored into two classes. One where @exhibit is present, and one where it isn't.
    def current_exhibit
      @exhibit
    end

    def blacklight_config
      if current_exhibit
        exhibit_specific_blacklight_config
      else
        default_catalog_controller.blacklight_config
      end
    end
    
    def search_action_url *args
      if current_exhibit
        spotlight.exhibit_catalog_index_url(current_exhibit, *args)
      else
        main_app.catalog_index_url *args
      end
    end

  end
end
