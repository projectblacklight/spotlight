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
      var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');
      
      if(dataCropperDiv) {
        var dataCropperKey = dataCropperDiv.data('cropper-key');
        var itemIndex = dataCropperDiv.data('index-id');
        var iiifFields = context.getIIIFObject(dataCropperKey, itemIndex);
        // The region field is set separately within the modal div
        iiifFields['iiifRegionField'] = context.setRegionField(dataCropperKey, itemIndex);
        new Crop(dataCropperDiv, iiifFields, false).render();
        //context.attachModalSaveHandler(dataCropperKey);
      }
    });
  }

  setRegionField(dataCropperKey, itemIndex) {
    var regionField = $('#blacklight-modal input[name="select_image_region');
    var itemElement = $('[data-cropper="' + dataCropperKey + '"]');
    var thumbnailUrl = this.iiifInputField(itemIndex, 'thumbnail_image_url', itemElement).val();
    var region = this.extractRegionField(thumbnailUrl);
    regionField.val(region);
    return regionField;
  }
  //When editing an existing/saved item, extract region values based on url
  extractRegionField(iiifThumbnailUrl) {
    if (iiifThumbnailUrl != null && iiifThumbnailUrl.length == 0) return null;

    var regex = /\/[0-9]+,[0-9]+,[0-9]+,[0-9]+\//;
    var match = iiifThumbnailUrl.match(regex);
    return match[0].replaceAll('/', '');
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
    return $(selector, parentElement);
  }

  attachModalSaveHandler() {
    var context = this;
    document.addEventListener('click', function(e) { 
      if(e.target.matches('#blacklight-modal input#saveimage')) {
        context.saveCroppedRegion();
      }
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
      // Get the region value saved in the modal for the selected area
      var regionElement = $('#blacklight-modal input[name="select_image_region"]');
      var regionValue = regionElement.val();
      // Extract the region string to incorporate into the thumbnail URL
      var urlPrefix = iiifTilesource.substring(0, iiifTilesource.lastIndexOf('/info.json'));
      var url = urlPrefix + "/" + regionValue + "/400,400/0/default.jpg";
      // Set the hidden inpt value to the thumbnail URL
      // Also set the full image - which may not be necessary for all widgets
      thumbnailSaveField.val(url);
      fullimageSaveField.val(url);
      // Also change img url for thumbnail image
      var itemImage = $('img.img-thumbnail', itemElement);      
      itemImage.attr('src', url);
    }
  }
}
