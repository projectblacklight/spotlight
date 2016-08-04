module Spotlight
  # View helpers for the ExhibitsController
  module ExhibitsHelper
    # use the specified crop points, but a bigger image than the thumbnail
    def card_image(exhibit)
      iiif_url = IIIFUrl.new exhibit.thumbnail.iiif_url
      iiif_url.size = Spotlight::Engine.config.featured_image_square_size
      iiif_url.to_s
    end
  end
end
