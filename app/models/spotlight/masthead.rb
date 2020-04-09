# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit and browse category mastheads
  class Masthead < Spotlight::FeaturedImage
    def display?
      display && iiif_url.present?
    end

    private

    def image_size
      Spotlight::Engine.config.featured_image_masthead_size
    end
  end
end
