# frozen_string_literal: true

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
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@contact_email) }
        format.json { render json: { success: true, error: nil } }
      end
    end

    private

    def record_not_found(_error)
      respond_to do |format|
        format.turbo_stream { head :not_found }
        format.json { render json: { success: false, error: 'Not Found' }, status: :not_found }
      end
    end
  end
end
