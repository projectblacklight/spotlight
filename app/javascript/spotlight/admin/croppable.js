import Crop from 'spotlight/admin/crop';
import CroppableModal from 'spotlight/admin/croppable_modal';

export default class Croppable {
  connect() {
    // For exhibit masthead or thumbnail pages, where
    // the div exists on page load
    /*
    $('[data-behavior="iiif-cropper"]').each(function() {
      var cropElement = $(this)
      new Crop(cropElement).render()
    })*/
    document.querySelectorAll('[data-behavior="iiif-cropper"]').forEach(cropElement => {
      console.log("Croppable query selector ");
      console.log(cropElement);
      //var cropElement = $(this)
      new Crop(cropElement).render()
    });

    // In the case of individual document thumbnails, selection
    // of the image is through a modal. Here we attach the event
    new CroppableModal().attachModalHandlers();
  }
}
