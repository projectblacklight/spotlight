module Spotlight
  ##
  # Create image attachments for the sir-trevor image widget
  class AttachmentsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :exhibit, class: 'Spotlight::Exhibit'
    load_and_authorize_resource through: :exhibit

    # POST /attachments
    def create
      @attachment.attributes = attachment_params
      @attachment.save!
      render json: @attachment
    end

    private

    # Only allow a trusted parameter "white list" through.
    def attachment_params
      params.require(:attachment).permit(:name, :file, :uid)
    end
  end
end
