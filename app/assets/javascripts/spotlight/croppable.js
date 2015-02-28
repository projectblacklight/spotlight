Spotlight.onLoad(function() {
  $('[data-croppable="true"]').croppable();
});


/*
  Croppable plugin
  Implements http://deepliquid.com/content/Jcrop.html
  Add jcrop data-attributes to file input (with data-croppable='true') to instantiate.
*/

(function($) {
  $.fn.croppable = function(opts) {
    var croppables = this;
    var opts = opts;
    var pluginDefults = {
      setSelect: "[0,0,200,200]"
    }

    $(croppables).each(function() {
      var fileUpload = $(this);
      var cropid = fileUpload.data('selector') || this.id;
      var cropinfo = $("#" + cropid + "_crop").val();
      var cropbox = $("#" + cropid + "_cropbox");
      var previewbox = $("#" + cropid + "_previewbox");

      var defaults = {
        setSelect: $.parseJSON(cropinfo || pluginDefults['setSelect']),
        selector: cropid
      }

      var options = $.extend(defaults, fileUpload.data(), opts);

      function updatePreview(coords) {
        previewbox.css({
          width: Math.round(100/coords.w * cropbox.width()) + 'px',
          height: Math.round(100/coords.h * cropbox.height()) + 'px',
          marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px',
          marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'
        });
      };

      function update(coords) {
        $('#' + cropid + '_crop_x').val(coords.x);
        $('#' + cropid + '_crop_y').val(coords.y);
        $('#' + cropid + '_crop_w').val(coords.w);
        $('#' + cropid + '_crop_h').val(coords.h);
        updatePreview(coords);
      };

      if(!cropbox.data('jcropProcessed')){
        cropbox.Jcrop(
          $.extend(options, {
            onSelect: update,
            onChange: update
          })
        );
      }
      cropbox.data('jcropProcessed', 'true');

      fileUpload.on('change', function() {
        var jcrop_api = cropbox.data('Jcrop');
        if(this.files){
          var file = this.files[0];
          var img = cropbox[0];

          img.file = file;

          var reader = new FileReader();

          reader.onload = (function(aImg) { return function(e) {
            jcrop_api.setImage(e.target.result);
            cropbox.css({width: "", height: ""});
            cropbox[0].src = e.target.result;
            if(previewbox.length > 0) {
              previewbox[0].src = e.target.result;
            }
            jcrop_api.setSelect([0,0,200,200]);
          }; })(img);
          reader.readAsDataURL(file);
        }else{
          var url = $(this).attr('value');
          jcrop_api.setImage(url);
          cropbox.css({width: "", height: ""});
          cropbox[0].src = url;
          if(previewbox.length > 0) {
            previewbox[0].src = url;
          }
          jcrop_api.setSelect([0,0,200,200]);
        }
        cropbox.closest('.missing-croppable').removeClass('missing-croppable');
      });

    });

    return this;
  };
})(jQuery);
