import Crop from 'spotlight/admin/crop';

export default class CroppableModal {

  attachModalHandlers() {
    // Attach handler for when modal first loads, to show the cropper
    this.attachModalLoadBehavior();
    // Attach handler for save by checking if clicking in the modal is on a save button
    this.attachModalSaveHandler();
  }

  attachModalLoadBehavior() {
    // Listen for event thrown when modal is displayed with content
    document.addEventListener('loaded.blacklight.blacklight-modal', function(e) {
      var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');
      
      if(dataCropperDiv) {
        new Crop(dataCropperDiv, false).render();
      }
    });
  }

  // Field names are of the format item[item_0][iiif_image_id]
  iiifInputField(itemIndex, fieldName, parentElement) {
    var itemPrefix = 'item[' + itemIndex + ']';
    var selector = 'input[name="' + itemPrefix + '[' + fieldName + ']"]';
    return $(selector, parentElement);
  }

  attachModalSaveHandler() {
    var context = this;
   
    document.addEventListener('show.blacklight.blacklight-modal', function(e) {
      $('#save-cropping-selection').on('click', () => {
        context.saveCroppedRegion();
      });
    });
  }

  saveCroppedRegion() {
    //On hitting "save changes", we need to copy over the value
    //to the iiif thumbnail url input field as well as the image source itself
    var context = this;
    var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');

    if(dataCropperDiv) {
      var dataCropperKey = dataCropperDiv.data("cropper-key");
      var itemIndex = dataCropperDiv.data("index-id");
      // Get the element on the main edit page whose select image link opened up the modal
      var itemElement = $('[data-cropper="' + dataCropperKey + '"]');
      // Get the hidden input field on the main edit page corresponding to this item
      var thumbnailSaveField = context.iiifInputField(itemIndex, 'thumbnail_image_url', itemElement);
      var fullimageSaveField = context.iiifInputField(itemIndex, 'full_image_url', itemElement);
      var iiifTilesource = context.iiifInputField(itemIndex, 'iiif_tilesource', itemElement).val();
      var regionValue = context.iiifInputField(itemIndex, 'iiif_region', itemElement).val();
      // Extract the region string to incorporate into the thumbnail URL
      var urlPrefix = iiifTilesource.substring(0, iiifTilesource.lastIndexOf('/info.json'));
      var thumbnailUrl = urlPrefix + '/' + regionValue + '/!400,400/0/default.jpg';
      // Set the hidden input value to the thumbnail URL
      // Also set the full image - which is used by widgets like carousel or slideshow
      thumbnailSaveField.val(thumbnailUrl);
      fullimageSaveField.val(urlPrefix + '/' + regionValue + '/!800,800/0/default.jpg');
      // Also change img url for thumbnail image
      var itemImage = $('img.img-thumbnail', itemElement);      
      itemImage.attr('src', thumbnailUrl);
    }
  }
}
