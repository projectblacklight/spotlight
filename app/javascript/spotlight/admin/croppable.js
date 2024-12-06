import Crop from 'spotlight/admin/crop';

export default class Croppable {
  connect() {
   this.initializeExistingCropper()
  }

  initializeExistingCropper() {
    $('[data-behavior="iiif-cropper"]').each(function() {
      var cropElement = $(this)
      new Crop(cropElement).render()
    })
  }
}
