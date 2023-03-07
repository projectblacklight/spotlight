import Crop from 'spotlight/admin/crop';

export default class {
  connect() {
    $('[data-behavior="iiif-cropper"]').each(function() {
      var cropElement = $(this)
      new Crop(cropElement).render()
    })
  }
}
