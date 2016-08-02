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

    # The create action can be called from a number of different forms, so
    # we normalize all the parameters.
    def create_params
      if params.key? :exhibit
        image_params(:exhibit)
      elsif params.key? :feature_page
        image_params(:feature_page)
      elsif params.key? :contact
        image_params(:contact, :avatar_attributes)
      end
    end

    # Params from the avatar/exhibit/feature_page image upload
    def image_params(key, association_key = :thumbnail_attributes)
      parent_params = params.fetch(key)
      if parent_params.key?(association_key)
        { image: parent_params.fetch(association_key).fetch(:file, {}) }
      else
        logger.warn "missing expected parameter #{key}[#{association_key}]. Found: #{parent_params.keys.join(', ')}"
        { image: {} }
      end
    end
  end
end
