import Crop from 'spotlight/admin/crop';

export default class Croppable {
  connect() {
    // For exhibit masthead or thumbnail pages, where
    // the div exists on page load
    $('[data-behavior="iiif-cropper"]').each(function() {
      var cropElement = $(this)
      new Crop(cropElement).render()
    })

    // In the case of individual document thumbnails, selection
    // of the image is through a modal. Here we attach the event
    this.attachModalHandler();
    //this.attachModalSaveHandler();
  }

  attachModalHandler() {
    var context  = this;
    document.addEventListener('show.blacklight.blacklight-modal', function(e) {      
      var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');
      
      if(dataCropperDiv) {
        var dataCropperKey = dataCropperDiv.data("cropper-key");
        var itemIndex = dataCropperDiv.data("index-id");
        var iiifFields = context.getIIIFObject(dataCropperKey, itemIndex);
        // The region field is set separately within the modal div
        iiifFields['iiifRegionField'] = context.setRegionField(dataCropperKey, itemIndex);
        new Crop(dataCropperDiv, iiifFields).render();
        context.attachModalSaveHandler(dataCropperKey);
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

  iiifInputField(itemIndex, fieldName, parentElement) {
    var itemPrefix = 'item[' + itemIndex + ']';
    var selector = 'input[name="' + itemPrefix + '[' + fieldName + ']"]';
    return $(selector, parentElement);
  }

  attachModalSaveHandler(dataCropperKey) {
    //On hitting "save changes", we need to copy over the value
    //to iiif thumbnail url
    var context = this;
    var modalSubmit = $('#blacklight-modal input#saveimage');
    var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');

    modalSubmit.on('click', function() {
      var itemIndex = dataCropperDiv.data("index-id");
      var itemElement = $('[data-cropper="' + dataCropperKey + '"]');
      var thumbnailSaveField = context.iiifInputField(itemIndex, 'thumbnail_image_url', itemElement);
      var iiifTilesource = context.iiifInputField(itemIndex, 'iiif_tilesource', itemElement).val();
      var regionElement = $('#blacklight-modal input[name="select_image_region"]');
      var regionValue = regionElement.val();
      var urlPrefix = iiifTilesource.substring(0, iiifTilesource.lastIndexOf('/info.json'));
      var url = urlPrefix + "/" + regionValue + "/400,400/0/default.jpg";
      thumbnailSaveField.val(url);
    });
  }
}
