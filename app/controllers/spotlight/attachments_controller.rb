module Spotlight
  class AttachmentsController < ApplicationController
    before_filter :authenticate_user!
    load_and_authorize_resource :exhibit, class: "Spotlight::Exhibit"
    load_and_authorize_resource through: :exhibit

    # POST /attachments
    def create
      @attachment.attributes = attachment_params
      if @attachment.save
        render :json => @attachment
      else
        render action: 'new'
      end
    end

    private

      # Only allow a trusted parameter "white list" through.
      def attachment_params
        params.require(:attachment).permit(:name, :file, :uid)
      end
  end
end
