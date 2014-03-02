module Spotlight
  class ConfirmationsController < Devise::ConfirmationsController
    # TODO this repeats lines from ApplicationController
    layout 'spotlight/spotlight'
    include Spotlight::Controller
    # end repetition

    protected

    def after_confirmation_path_for(resource_name, resource)
      if signed_in?
        exhibit_root_path(resource.exhibit)
      else
        main_app.new_user_session_path
      end
    end

    def after_resending_confirmation_instructions_path_for(resource_name)
      main_app.root_path
    end
  end
end
