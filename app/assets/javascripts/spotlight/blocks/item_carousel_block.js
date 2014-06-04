//= require 'spotlight/blocks/multi_up_item_grid.js'
SirTrevor.Blocks.ItemCarousel =  (function(){

  return SirTrevor.Blocks.MultiUpItemGrid.extend({

    type: "item-carousel",

    title: function() { return "Carousel"; },

    icon_name: "item-carousel",

    description: "This widget displays one to five thumbnail images of repository items in a carousel. You can configure the captions that appear below each carousel image and how the images are cycled."
  });
})();;