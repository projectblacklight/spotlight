# frozen_string_literal: true

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
      attachment_json = @attachment.as_json
      attachment_json['tilesource'] = tilesource
      render json: attachment_json
    end

    private

    def tilesource
      Spotlight::Engine.config.iiif_service.info_url(@attachment, request.host)
    end

    # Only allow trusted parameters through.
    def attachment_params
      params.require(:attachment).permit(:name, :file, :uid)
    end
  end
end
