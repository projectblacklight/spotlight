module Spotlight
  ##
  # Custom {Devise::ConfirmationsController} with spotlight behaviors
  class ConfirmationsController < Devise::ConfirmationsController
    layout 'spotlight/spotlight'

    protected

    def after_confirmation_path_for(_resource_name, resource)
      if signed_in?
        exhibit_root_path(resource.exhibit)
      else
        main_app.new_user_session_path
      end
    end

    def after_resending_confirmation_instructions_path_for(_resource_name)
      main_app.root_path
    end
  end
end
