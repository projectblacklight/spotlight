require 'spotlight'

module Spotlight
  # Inherit from the host app's ApplicationController
  # This will configure e.g. the layout used by the host
  class ApplicationController < ::ApplicationController
    layout 'spotlight/spotlight'

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to main_app.root_url, :alert => exception.message
    end

    def search_action_url *args
      if current_exhibit
        exhibit_catalog_index_url(current_exhibit, *args)
      else
        main_app.catalog_index_url *args
      end
    end
  end
end
