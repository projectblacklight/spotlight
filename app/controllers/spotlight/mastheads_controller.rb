module Spotlight
  # Handles requests to upload images for exhibit and site masthead images
  class MastheadsController < FeaturedImagesController
    private

    def create_params
      { image: parent_param
        .fetch(:masthead_attributes, {})
        .fetch(:image, {}) }
    end

    def parent_param
      params[:site] || params[:exhibit] || {}
    end
  end
end
