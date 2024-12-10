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
    this.attachModalHandler()
  }

  attachModalHandler() {
    console.log("Attaching modal handler");
    var context  = this;
    document.addEventListener('show.blacklight.blacklight-modal', function(e) {
      console.log("Attach Modal Handler");
      
      var dataCropperDiv = $('#blacklight-modal [data-behavior="iiif-cropper"]');
      
      if(dataCropperDiv) {
        var dataCropperKey = dataCropperDiv.data("cropper-key");
        console.log(dataCropperKey);
        var itemIndex = dataCropperDiv.data("index-id");
        console.log("itemIndex " + itemIndex);
        console.log("Get iiif fields");
        var iiifFields = context.getIIIFObject(dataCropperKey, itemIndex);
        new Crop(dataCropperDiv, iiifFields).render();
      }
      
    });
    
  }

  getIIIFObject(dataCropperKey, itemIndex) {
    var iiifFields = {};

    //Retrieve the fields from the main page with the itemIndex

    var itemElement = $('[data-cropper="' + dataCropperKey + '"]');
    var itemPrefix = 'input[name="item[' + itemIndex + ']';
    console.log(itemPrefix);

    iiifFields['iiifUrlField'] = this.iiifInputField(itemIndex, 'iiif_tilesource', itemElement);
    iiifFields['iiifRegionField'] = this.iiifInputField(itemIndex, 'iiif_region', itemElement);
    iiifFields['iiifManifestField'] = this.iiifInputField(itemIndex, 'iiif_manifest_url', itemElement);
    iiifFields['iiifCanvasField'] = this.iiifInputField(itemIndex, 'iiif_canvas_id', itemElement);
    iiifFields['iiifImageField'] = this.iiifInputField(itemIndex, 'iiif_image_id', itemElement);

    var testUrlField = this.iiifInputField(itemIndex, 'iiif_tilesource', itemElement);
    console.log("test url field");
    console.log(testUrlField);
    console.log("resulting iiif fields");
    console.log(iiifFields);
    return iiifFields;
    
  }

  iiifInputField(itemIndex, fieldName, parentElement) {
    var itemPrefix = 'item[' + itemIndex + ']';
    var selector = 'input[name="' + itemPrefix + '[' + fieldName + ']"]';
    console.log(selector);
    return $(selector, parentElement);
  }
}
