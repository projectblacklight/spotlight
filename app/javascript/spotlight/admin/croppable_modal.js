import Crop from 'spotlight/admin/crop';

export default class CroppableModal {

  attachModalHandlers() {
    // Attach handler for when modal first loads, to show the cropper
    this.attachModalLoadBehavior();
    // Attach handler for save by checking if clicking in the modal is on a save button
    this.attachModalSaveHandler();
  }

  attachModalLoadBehavior() {
    var context = this;
    // Listen for event thrown when modal is displayed with content
    document.addEventListener('show.blacklight.blacklight-modal', function(e) {      
      //var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');
      var dataCropperDiv = document.querySelector('#blacklight-modal [data-behavior="iiif-cropper"]');
      if(dataCropperDiv) {
        var dataCropperKey = dataCropperDiv.dataset.cropperKey;
        var itemIndex = dataCropperDiv.dataset.indexId;
        new Crop(dataCropperDiv, false).render();
      }
    });
  }

  getIIIFObject(dataCropperKey, itemIndex) {
    var iiifFields = {};
    //Retrieve the fields from the main page with the itemIndex
    var itemElement = $('[data-cropper="' + dataCropperKey + '"]');
    iiifFields['iiifUrlField'] = this.iiifInputField(itemIndex, 'iiif_tilesource', itemElement);
    iiifFields['iiifManifestField'] = this.iiifInputField(itemIndex, 'iiif_manifest_url', itemElement);
    iiifFields['iiifCanvasField'] = this.iiifInputField(itemIndex, 'iiif_canvas_id', itemElement);
    iiifFields['iiifImageField'] = this.iiifInputField(itemIndex, 'iiif_image_id', itemElement);
    return iiifFields;
  }

  // Field names are of the format item[item_0][iiif_image_id]
  iiifInputField(itemIndex, fieldName, parentElement) {
    var itemPrefix = 'item[' + itemIndex + ']';
    var selector = 'input[name="' + itemPrefix + '[' + fieldName + ']"]';
    var test = parentElement.querySelector(selector);
    console.log("iiif input field");
    console.log(test);
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
    var dataCropperdivTest = document.querySelector('#blacklight-modal [data-behavior="iiif-cropper"]');
    console.log("save cropped region");
    console.log(dataCropperdivTest);
    //var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');
    var dataCropperDiv = document.querySelector('#blacklight-modal [data-behavior="iiif-cropper"]');

    if(dataCropperDiv) {
      //var dataCropperKey = dataCropperDiv.data("cropper-key");
      var dataCropperKey = dataCropperDiv.dataset.cropperKey;
      //var itemIndex = dataCropperDiv.data("index-id");
      var itemIndex = dataCropperDiv.dataset.indexId;
      // Get the element on the main edit page whose select image link opened up the modal
      //var itemElement = $('[data-cropper="' + dataCropperKey + '"]');
      var itemElement = document.querySelector('[data-cropper="' + dataCropperKey + '"]');
      // Get the hidden input field on the main edit page corresponding to this item
      var thumbnailSaveField = context.iiifInputField(itemIndex, 'thumbnail_image_url', itemElement);
      var fullimageSaveField = context.iiifInputField(itemIndex, 'full_image_url', itemElement);
      var iiifTilesource = context.iiifInputField(itemIndex, 'iiif_tilesource', itemElement).value;
      var regionValue = context.iiifInputField(itemIndex, 'iiif_region', itemElement).value;
      // Extract the region string to incorporate into the thumbnail URL
      var urlPrefix = iiifTilesource.substring(0, iiifTilesource.lastIndexOf('/info.json'));
      var thumbnailUrl = urlPrefix + '/' + regionValue + '/!400,400/0/default.jpg';
      // Set the hidden inpt value to the thumbnail URL
      // Also set the full image - which is used by widgets like carousel or slideshow
      thumbnailSaveField.value = thumbnailUrl;
      fullimageSaveField.valye = urlPrefix + '/' + regionValue + '/!800,800/0/default.jpg';
      // Also change img url for thumbnail image
      //var itemImage = $('img.img-thumbnail', itemElement);      
      //itemImage.attr('src', thumbnailUrl);
      var itemImage = itemElement.querySelector('img.img-thumbnail');  
      itemImage.setAttribute('src', thumbnailUrl);
    }
  }
}
