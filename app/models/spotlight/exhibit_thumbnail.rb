# frozen_string_literal: true

module Spotlight
  ##
  # A simple sub-class of FeaturedImage to store the
  # square thumbnail used on the exhibits landing page
  class ExhibitThumbnail < Spotlight::FeaturedImage
    private

    def image_size
      Spotlight::Engine.config.featured_image_square_size
    end
  end
end
