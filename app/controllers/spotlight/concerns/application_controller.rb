require 'spotlight'

module Spotlight
  module Concerns
    # Inherit from the host app's ApplicationController
    # This will configure e.g. the layout used by the host
    module ApplicationController
      extend ActiveSupport::Concern
      include Spotlight::Controller

      included do
        layout 'spotlight/spotlight'

        helper Spotlight::ApplicationHelper

        rescue_from CanCan::AccessDenied do |exception|
          if current_exhibit && !can?(:read, current_exhibit)
            # Try to authenticate the user
            authenticate_user!

            # If that fails (and we end up back here), offer a 404 error instead
            fail ActionController::RoutingError, 'Not Found'
          else
            redirect_to main_app.root_url, alert: exception.message
          end
        end
      end
    end
  end
end
