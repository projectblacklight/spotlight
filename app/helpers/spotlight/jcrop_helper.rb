module Spotlight
  module JcropHelper
    def default_masthead_jcrop_options
      {
        croppable: true,
        selector: 'masthead_image',
        bg_color: 'black',
        bg_opacity: '.4',
        max_size: '[1800,131]',
        min_size: '[1200,120]',
        box_width: '600',
        set_select: '[0,0,1800,131]'
      }
    end
  end
end
