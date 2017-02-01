module Spotlight
  ##
  # Exhibit and browse category mastheads
  class Masthead < Spotlight::FeaturedImage
    def display?
      display && iiif_url.present?
    end

    private

    def image_size
      [1800, 180]
    end
  end
end
