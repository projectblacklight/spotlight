//= require 'spotlight/blocks/multi_up_item_grid.js'
SirTrevor.Blocks.ItemFeatures =  (function(){

  return SirTrevor.Blocks.MultiUpItemGrid.extend({

    type: "item-features",

    title: function() { return "Featured Items"; },

    icon_name: "item-features",

    description: "This widget displays one to five thumbnail images of repository items in a slideshow."
  });
})();;

Spotlight.onLoad(function(){
  var indicators = $('.item-features .slideshow-indicators li');
  indicators.each(function(){
    $(this).on('click', function(){
      indicators.removeClass("active");
      $(this).addClass("active");
    });
  });
});
