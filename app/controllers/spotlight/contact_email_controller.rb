module Spotlight
  ##
  # CRUD actions for exhibit contact emails
  class ContactEmailController < Spotlight::ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    load_and_authorize_resource through: :exhibit

    def destroy
      @contact_email.destroy
      render json: { success: true, error: nil }
    end

    private

    def record_not_found(_error)
      render json: { success: false, error: 'Not Found' }, status: :not_found
    end
  end
end
