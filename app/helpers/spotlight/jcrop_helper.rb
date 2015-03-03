module Spotlight
  module JcropHelper
    def default_masthead_jcrop_options
      {
        croppable: true,
        selector: 'masthead_image',
        bg_color: 'black',
        bg_opacity: '.4',
        aspect_ratio: 15,
        box_width: '600'
      }
    end
  end
end
