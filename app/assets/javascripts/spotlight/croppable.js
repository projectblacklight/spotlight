Spotlight.onLoad(function() {
  $('[data-croppable="true"]').croppable();
});


/*
  Croppable plugin
  Implements http://deepliquid.com/content/Jcrop.html
  Add jcrop data-attributes to file input (with data-croppable='true') to instantiate.
  Adds initialSetSelect option to set a select box on the intial upload of an object.
*/

var xosd;  // debug -- remove.
(function($) {
  $.fn.croppable = function(opts) {
    var croppables = this;
    var opts = opts;

    // TODO initial selection
    var pluginDefults = {
      setSelect: "[0,0,200,200]"
    }

    var Crop = require('spotlight/crop');
    $(croppables).each(function() {
      var fileUpload = $(this);
      new Crop(fileUpload) 
    });

    return this;
  };
})(jQuery);
