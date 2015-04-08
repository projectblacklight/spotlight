require 'spotlight'

module Spotlight
  ##
  # Inherit from the host app's ApplicationController
  # This will configure e.g. the layout used by the host
  class ApplicationController < ::ApplicationController
    include Spotlight::Concerns::ApplicationController

    before_action do
      flash.now[:notice] = flash[:notice].html_safe if flash[:html_safe] && flash[:notice]
    end
  end
end
