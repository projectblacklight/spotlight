module Spotlight
  # Handles requests to upload images for exhibit thumbnails
  class FeaturedImagesController < Spotlight::ApplicationController
    load_and_authorize_resource instance_name: :featured_image

    def create
      @featured_image.save!
      if @featured_image.image.file
        render json: { tilesource: tilesource, id: @featured_image.id }
      else
        render json: { error: 'unable to create image' }, status: :bad_request
      end
    end

    private

    def tilesource
      riiif.info_url(@featured_image.id)
    end

    def create_params
      { image: params.fetch(:exhibit, {})
                     .fetch(:featured_image_attributes, {})
                     .fetch(:image, {}) }
    end
  end
end
