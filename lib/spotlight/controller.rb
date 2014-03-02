module Spotlight
  module Controller
    extend ActiveSupport::Concern
    include Blacklight::Controller
    include Spotlight::Config

    included do
      helper_method :current_exhibit
    end

    def current_exhibit
      @exhibit
    end

    def blacklight_config
      exhibit_specific_blacklight_config
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
