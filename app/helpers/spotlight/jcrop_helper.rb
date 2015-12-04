module Spotlight
  ##
  # JCrop options helpers
  module JcropHelper
    def default_masthead_jcrop_options
      {
        croppable: true,
        selector: 'masthead_image',
        bg_color: 'black',
        bg_opacity: '.4',
        aspect_ratio: 10,
        box_width: '600',
        initial_set_select: '[0, 0, 1800, 180]'
      }
    end

    def default_thumbnail_jcrop_options
      w, h = Spotlight::Engine.config.featured_image_thumb_size

      {
        croppable: true,
        selector: 'featuredimage_image',
        bg_color: 'black',
        bg_opacity: '.4',
        box_width: '600',
        aspect_ratio: w.to_f / h.to_f,
        initial_set_select: '[0, 0, 100000, 100000]'
      }
    end

    def default_site_thumbnail_jcrop_options
      w, h = Spotlight::Engine.config.featured_image_square_size

      default_thumbnail_jcrop_options.merge(aspect_ratio: w.to_f / h.to_f)
    end
  end
end
