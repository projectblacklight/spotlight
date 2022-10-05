# frozen_string_literal: true

module Spotlight
  # Handles requests to upload images for exhibit thumbnails
  class FeaturedImagesController < Spotlight::ApplicationController
    load_and_authorize_resource instance_name: :featured_image, class: 'Spotlight::TemporaryImage'

    def create
      if @featured_image.save && @featured_image.file_present?
        render json: { tilesource: tilesource, id: @featured_image.id }
      else
        render json: { error: 'unable to create image' }, status: :bad_request
      end
    end

    private

    def tilesource
      Spotlight::Engine.config.iiif_service.info_url(@featured_image)
    end

    # The create action can be called from a number of different forms, so
    # we normalize all the parameters.
    def create_params
      params.require(:featured_image).permit(:image)
    end
  end
end
