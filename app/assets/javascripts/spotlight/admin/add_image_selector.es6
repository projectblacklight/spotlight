export default class {
  constructor(input, panel, manifestUrl, initialize) {
    this.input = input
    this.panel = panel
    this.manifestUrl = manifestUrl
    this.initialize = initialize
  }

  connect() {
    if (!this.manifestUrl) {
      this.showNonIiifAlert();
      return;
    }
    var cropper = this.input.data('iiifCropper');
    const self = this

    $.ajax(this.manifestUrl).done(
      function(manifest) {
        var Iiif = spotlightAdminIiif;
        var iiifManifest = new Iiif(this.manifestUrl, manifest);

        var thumbs = iiifManifest.imagesArray();

        self.hideNonIiifAlert();

        if (self.initialize) {
          cropper.setIiifFields(thumbs[0]);
          self.panel.multiImageSelector(); // Clears out existing selector
        }

        if(thumbs.length > 1) {
          self.panel.show();
          self.panel.multiImageSelector(thumbs, function(selectorImage) {
            cropper.setIiifFields(selectorImage);
          }, cropper.iiifImageField.val());
        }
      }
    );
  }

  showNonIiifAlert(){
    this.input.parent().prev('[data-behavior="non-iiif-alert"]').show();
  }

  hideNonIiifAlert(){
    this.input.parent().prev('[data-behavior="non-iiif-alert"]').hide();
  }
}