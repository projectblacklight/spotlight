import Iiif from 'iiif'

export function addImageSelector(input, panel, manifestUrl, initialize) {
  if (!manifestUrl) {
    showNonIiifAlert(input);
    return;
  }
  var cropper = input.data('iiifCropper');
  $.ajax(manifestUrl).done(
    function(manifest) {
      var iiifManifest = new Iiif(manifestUrl, manifest);

      var thumbs = iiifManifest.imagesArray();

      hideNonIiifAlert(input);

      if (initialize) {
        cropper.setIiifFields(thumbs[0]);
        panel.multiImageSelector(); // Clears out existing selector
      }

      if(thumbs.length > 1) {
        panel.show();
        panel.multiImageSelector(thumbs, function(selectorImage) {
          cropper.setIiifFields(selectorImage);
        }, cropper.iiifImageField.val());
      }
    }
  );
}

function showNonIiifAlert(input){
  input.parent().prev('[data-behavior="non-iiif-alert"]').show();
}

function hideNonIiifAlert(input){
  input.parent().prev('[data-behavior="non-iiif-alert"]').hide();
}