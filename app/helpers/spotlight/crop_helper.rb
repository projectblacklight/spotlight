module Spotlight
  ##
  # iiif-crop options helpers
  module CropHelper
    def masthead_crop_options
      {
        croppable: true,
        selector: 'masthead_image',
        initial_set_select: [0, 0, 1800, 180]
      }
    end

    def thumbnail_crop_options
      w, h = Spotlight::Engine.config.featured_image_thumb_size

      {
        croppable: true,
        selector: 'featuredimage_image',
        initial_set_select: [0, 0, h, w]
      }
    end

    def site_thumbnail_crop_options
      w, h = Spotlight::Engine.config.featured_image_square_size
      thumbnail_crop_options.merge(initial_set_select: [0, 0, h, w])
    end
  end
end
