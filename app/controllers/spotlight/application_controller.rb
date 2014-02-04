require 'spotlight'

module Spotlight
  # Inherit from the host app's ApplicationController
  # This will configure e.g. the layout used by the host
  class ApplicationController < ::ApplicationController
    layout 'spotlight/spotlight'

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to main_app.root_url, :alert => exception.message
    end

  end
end
