module Spotlight
  class ConfirmationsController < Devise::ConfirmationsController
    # TODO this repeats lines from ApplicationController
    layout 'spotlight/spotlight'
    include Blacklight::Controller
    include Spotlight::Controller
    def search_action_url *args
      if current_exhibit
        exhibit_catalog_index_url(current_exhibit, *args)
      else
        main_app.catalog_index_url *args
      end
    end
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
