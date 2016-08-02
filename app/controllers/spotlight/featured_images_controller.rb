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
        exhibit_params
      elsif params.key? :contact
        contact_params
      end
    end

    # Params from the exhibit thumbnail
    def exhibit_params
      exhibit_params = params.fetch(:exhibit)
      if exhibit_params.key?(:thumbnail_attributes)
        { image: exhibit_params.fetch(:thumbnail_attributes).fetch(:image, {}) }
      else
        logger.warn "missing expected parameter exhibit[thumbnail_attributes]. Found: #{exhibit_params.keys.join(', ')}"
        { image: {} }
      end
    end

    # Params from the contact avatar upload
    def contact_params
      contact_params = params.fetch(:contact)
      logger.info "Contact params: #{contact_params.keys.inspect}"
      if contact_params.key?(:file)
        { image: contact_params.fetch(:file) }
      else
        logger.warn "missing expected parameter contact[file]. Found: #{contact_params.keys.join(', ')}"
        { image: {} }
      end
    end
  end
end
