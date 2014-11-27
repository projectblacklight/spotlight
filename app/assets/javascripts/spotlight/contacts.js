Spotlight.onLoad(function() {
  $('#contact_avatar').croppable();
});

(function($) {
  $.fn.croppable = function(params) {
    var croppables = this;

    $(croppables).each(function() {
      var cropinfo = $("#" + this.id + "_crop").val();
      var cropbox = $("#" + this.id + "_cropbox");
      var previewbox = $("#" + this.id + "_previewbox");

      function updatePreview(coords) {
        previewbox.css({
          width: Math.round(100/coords.w * cropbox.width()) + 'px',
          height: Math.round(100/coords.h * cropbox.height()) + 'px',
          marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px',
          marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'
        });
      };

      function update(coords) {
        $('#contact_avatar_crop_x').val(coords.x);
        $('#contact_avatar_crop_y').val(coords.y);
        $('#contact_avatar_crop_w').val(coords.w);
        $('#contact_avatar_crop_h').val(coords.h);
        updatePreview(coords);
      };

      cropbox.Jcrop({
        aspectRatio: 1,
        setSelect: $.parseJSON(cropinfo || "[0,0,200,200]"),
        onSelect: update,
        onChange: update
      });

      $(this).on('change', function() {

        var file = this.files[0];
        var img = cropbox[0];

        img.file = file;

        var reader = new FileReader();

        reader.onload = (function(aImg) { return function(e) {
          var jcrop_api = cropbox.data('Jcrop');
          jcrop_api.setImage(e.target.result);
          cropbox.css({width: "", height: ""});
          cropbox[0].src = e.target.result;
          previewbox[0].src = e.target.result;
          jcrop_api.setSelect([0,0,200,200]);
        }; })(img);

        cropbox.closest('.avatar-missing').removeClass('avatar-missing');

        reader.readAsDataURL(file);

      });

    });

    return this;
  };
})(jQuery);
