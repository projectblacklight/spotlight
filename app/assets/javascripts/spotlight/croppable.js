Spotlight.onLoad(function() {
  $('[data-croppable="true"]').croppable();
});


/*
  IIIF image cropping plugin
  Add iiif-crop data-attributes to file input (with data-croppable='true') to instantiate.
*/

var xosd;  // TODO debug -- remove.
(function($) {
  $.fn.croppable = function() {
    var croppables = this;

    var Crop = require('spotlight/crop');
    $(croppables).each(function() {
      var fileUpload = $(this);
      new Crop(fileUpload) 
    });

    return this;
  };
})(jQuery);
