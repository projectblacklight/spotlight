Spotlight.onLoad(function() {
  $('[data-behavior="iiif-cropper"]').croppable();
});


/*
  IIIF image cropping plugin
  Add iiif-crop data-attributes to file input (with data-behavior='iiif-cropper') to instantiate.
*/

(function($) {
  $.fn.croppable = function() {
    var croppables = this;

    var Crop = require('spotlight/admin/crop');
    $(croppables).each(function() {
      var cropElement = $(this);
      var c = new Crop(cropElement);

      c.render();
    });

    return this;
  };
})(jQuery);
