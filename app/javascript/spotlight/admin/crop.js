import { addImageSelector } from 'spotlight/admin/add_image_selector'
import Core from 'spotlight/core'

export default class Crop {
  constructor(cropArea, preserveAspectRatio = true) {
    this.cropArea = cropArea;
    this.cropArea.data('iiifCropper', this);
    // This element will also have the IIIF input elements contained
    // There may be multiple elements with data-cropper attributes, but
    // there should only one element with this data-cropper attribute value.
    this.cropSelector = '[data-cropper="' + cropArea.data('cropperKey') + '"]';
    this.cropTool = $(this.cropSelector);
    // Exhibit and masthead cropping requires the ratio between image width and height
    // to be consistent, whereas item widget cropping allows any combination of 
    // image width and height.
    this.preserveAspectRatio = preserveAspectRatio;
    // Get the IIIF input elements used to store/reference IIIF information
    this.inputPrefix = this.cropTool.data('input-prefix');
    this.iiifUrlField = this.iiifInputElement(this.inputPrefix, 'iiif_tilesource', this.cropTool);
    this.iiifRegionField = this.iiifInputElement(this.inputPrefix, 'iiif_region', this.cropTool);
    this.iiifManifestField = this.iiifInputElement(this.inputPrefix, 'iiif_manifest_url', this.cropTool);
    this.iiifCanvasField = this.iiifInputElement(this.inputPrefix, 'iiif_canvas_id', this.cropTool);
    this.iiifImageField = this.iiifInputElement(this.inputPrefix, 'iiif_image_id', this.cropTool);
    // Get the closest form element
    this.form = cropArea.closest('form');
    this.tileSource = null;
  }

  // Return the iiif input element based on the fieldname.
  // Multiple input fields with the same name on the page may be related 
  // to a cropper. We thus need to pass in a parent element. 
  iiifInputElement(inputPrefix, fieldName, inputParentElement) {
    return $('input[name="' + inputPrefix + '[' + fieldName + ']"]', inputParentElement);
  }

  // Render the cropper environment and add hooks into the autocomplete and upload forms
  render() {
    this.setupAutoCompletes();
    this.setupAjaxFileUpload();
    this.setupExistingIiifCropper();
  }

  // Setup the cropper on page load if the field
  // that holds the IIIF url is populated
  setupExistingIiifCropper() {
    if(this.iiifUrlField.val() === '') {
      return;
    }

    this.addImageSelectorToExistingCropTool();
    this.setTileSource(this.iiifUrlField.val());
  }

  // Display the IIIF Cropper map with the current IIIF Layer (and cropbox, once the layer is available)
  setupIiifCropper() {
    this.loaded = false;

    this.renderCropperMap();

    if (this.imageLayer) {
      // Force a broken layer's container to be an element before removing.
      // Code in leaflet-iiif land calls delete on the image layer's container when removing,
      // which errors if there is an issue fetching the info.json and stops further necessary steps to execute.
      if(!this.imageLayer._container) {
        this.imageLayer._container = $('<div></div>');
      }
      this.cropperMap.removeLayer(this.imageLayer);
    }

    this.imageLayer = L.tileLayer.iiif(this.tileSource).addTo(this.cropperMap);

    var self = this;
    this.imageLayer.on('load', function() {
      if (!self.loaded) {
        var region = self.getCropRegion();
        self.positionIiifCropBox(region);
        self.loaded = true;
      }
    });

    this.cropArea.data('initiallyVisible', this.cropArea.is(':visible'));
  }

  // Get (or initialize) the current crop region from the form data
  getCropRegion() {
    var regionFieldValue = this.iiifRegionField.val();
    if(!regionFieldValue || regionFieldValue === '') {
      var region = this.defaultCropRegion();
      this.iiifRegionField.val(region);
      return region;
    } else {
      return regionFieldValue.split(',');
    }
  }

  // Calculate a default crop region in the center of the image using the correct aspect ratio
  defaultCropRegion() {
    var imageWidth = this.imageLayer.x;
    var imageHeight = this.imageLayer.y;

    var boxWidth = Math.floor(imageWidth / 2);
    var boxHeight = Math.floor(boxWidth / this.aspectRatio());

    return [
      Math.floor((imageWidth - boxWidth) / 2),
      Math.floor((imageHeight - boxHeight) / 2),
      boxWidth,
      boxHeight
    ];
  }

  // Calculate the required aspect ratio for the crop area
  aspectRatio() {
    var cropWidth = parseInt(this.cropArea.data('crop-width'));
    var cropHeight = parseInt(this.cropArea.data('crop-height'));
    return cropWidth / cropHeight;
  }

  // Position the IIIF Crop Box at the given IIIF region
  positionIiifCropBox(region) {
    var bounds = this.unprojectIIIFRegionToBounds(region);

    if (!this.cropBox) {
      this.renderCropBox(bounds);
    }

    this.cropBox.setBounds(bounds);
    this.cropperMap.invalidateSize();
    this.cropperMap.fitBounds(bounds);

    this.cropBox.editor.editLayer.clearLayers();
    this.cropBox.editor.refresh();
    this.cropBox.editor.initVertexMarkers();
  }

  // Set all of the various input fields to
  // the appropriate IIIF URL or identifier
  setIiifFields(iiifObject) {
    this.setTileSource(iiifObject.tilesource);
    this.iiifManifestField.val(iiifObject.manifest);
    this.iiifCanvasField.val(iiifObject.canvasId);
    this.iiifImageField.val(iiifObject.imageId);
  }

  // Set the Crop tileSource and setup the cropper
  setTileSource(source) {
    if (source == this.tileSource) {
      return;
    }

    if (source === null || source === undefined) {
      console.error('No tilesource provided when setting up IIIF Cropper');
      return;
    }

    if (this.cropBox) {
      this.iiifRegionField.val("");
    }

    this.tileSource = source;
    this.iiifUrlField.val(source);
    this.setupIiifCropper();
  }

  // Render the Leaflet Map into the crop area
  renderCropperMap() {
    if (this.cropperMap) {
      return;
    }

    var cropperOptions = {
      editable: true,
      center: [0, 0],
      crs: L.CRS.Simple,
      zoom: 0
    }

    if(this.preserveAspectRatio) {
      cropperOptions['editOptions'] = {
        rectangleEditorClass: this.aspectRatioPreservingRectangleEditor(this.aspectRatio())
      };
    }

    this.cropperMap = L.map(this.cropArea.attr('id'), cropperOptions);
    this.invalidateMapSizeOnTabToggle();
  }

  // Render the crop box (a Leaflet editable rectangle) onto the canvas
  renderCropBox(initialBounds) {
    this.cropBox = L.rectangle(initialBounds);
    this.cropBox.addTo(this.cropperMap);
    this.cropBox.enableEdit();
    this.cropBox.on('dblclick', L.DomEvent.stop).on('dblclick', this.cropBox.toggleEdit);

    var self = this;
    this.cropperMap.on('editable:dragend editable:vertex:dragend', function(e) {
      var bounds = e.layer.getBounds();
      var region = self.projectBoundsToIIIFRegion(bounds);

      self.iiifRegionField.val(region.join(','));
    });
  }

  // Get the maximum zoom level for the IIIF Layer (always 1:1 image pixel to canvas?)
  maxZoom() {
    if(this.imageLayer) {
      return this.imageLayer.maxZoom;
    }
  }

  // Take a Leaflet LatLngBounds object and transform it into a IIIF [x, y, w, h] region
  projectBoundsToIIIFRegion(bounds) {
    var min = this.cropperMap.project(bounds.getNorthWest(), this.maxZoom());
    var max = this.cropperMap.project(bounds.getSouthEast(), this.maxZoom());
    return [
      Math.max(Math.floor(min.x), 0),
      Math.max(Math.floor(min.y), 0),
      Math.floor(max.x - min.x),
      Math.floor(max.y - min.y)
    ];
  }

  // Take a IIIF [x, y, w, h] region and transform it into a Leaflet LatLngBounds
  unprojectIIIFRegionToBounds(region) {
    var minPoint = L.point(parseInt(region[0]), parseInt(region[1]));
    var maxPoint = L.point(parseInt(region[0]) + parseInt(region[2]), parseInt(region[1]) + parseInt(region[3]));

    var min = this.cropperMap.unproject(minPoint, this.maxZoom());
    var max = this.cropperMap.unproject(maxPoint, this.maxZoom());
    return L.latLngBounds(min, max);
  }

  // TODO: Add accessors to update hidden inputs with IIIF uri/ids?

  // Setup autocomplete inputs to have the iiif_cropper context
  setupAutoCompletes() {
    var input = $('[data-behavior="autocomplete"]', this.cropTool);
    input.data('iiifCropper', this);
  }

  setupAjaxFileUpload() {
    this.fileInput = $('input[type="file"]', this.cropTool);
    this.fileInput.change(() => this.uploadFile());
  }

  addImageSelectorToExistingCropTool() {
    if(this.iiifManifestField.val() === '') {
      return;
    }

    var input = $('[data-behavior="autocomplete"]', this.cropTool);
    
    // Not every page which uses this module has autocomplete linked directly to the cropping tool
    if(input.length) {
      var panel = $(input.data('target-panel'));
      addImageSelector(input, panel, this.iiifManifestField.val(), !this.iiifImageField.val());
    }
  }

  invalidateMapSizeOnTabToggle() {
    var tabs = $('[role="tablist"]', this.form);
    var self = this;
    tabs.on('shown.bs.tab', function() {
      if(self.cropArea.data('initiallyVisible') === false && self.cropArea.is(':visible')) {
        self.cropperMap.invalidateSize();
        // Because the map size is 0,0 when image is loading (not visible) we need to refit the bounds of the layer
        self.imageLayer._fitBounds();
        self.cropArea.data('initiallyVisible', null);
      }
    });
  }

  // Get all the form data with the exception of the _method field.
  getData() {
    var data = new FormData(this.form[0]);
    data.append('_method', null);
    return data;
  }

  uploadFile() {
    var url = this.fileInput.data('endpoint')
    // Every post creates a new image/masthead.
    // Because they create IIIF urls which are heavily cached.
    $.ajax({
      url: url,  //Server script to process data
      type: 'POST',
      success: (data, stat, xhr) => this.successHandler(data, stat, xhr),
      // error: errorHandler,
      // Form data
      data: this.getData(),
      headers: {
        'X-CSRF-Token': Core.csrfToken() || ''
      },
      //Options to tell jQuery not to process data or worry about content-type.
      cache: false,
      contentType: false,
      processData: false
    });
  }

  successHandler(data, stat, xhr) {
    this.setIiifFields({ tilesource: data.tilesource });
    this.setUploadId(data.id);
  }

  setUploadId(id) {
    // This input is currently used for exhibit masthead or thumbnail image upload.
    // The name should be sufficient in this case, as we don't use this part of the
    // code for solr document widgets where we enable cropping. 
    // If we require more specificity, we can scope this to this.cropTool. 
    $('input[name="' + this.inputPrefix + '[upload_id]"]').val(id);
  }

  aspectRatioPreservingRectangleEditor(aspect) {
    return L.Editable.RectangleEditor.extend({
      extendBounds: function (e) {
        var index = e.vertex.getIndex(),
            next = e.vertex.getNext(),
            previous = e.vertex.getPrevious(),
            oppositeIndex = (index + 2) % 4,
            opposite = e.vertex.latlngs[oppositeIndex];

        if ((index % 2) == 1) {
          // calculate horiz. displacement
          e.latlng.update([opposite.lat + ((1 / aspect) * (opposite.lng - e.latlng.lng)), e.latlng.lng]);
        } else {
          // calculate vert. displacement
          e.latlng.update([e.latlng.lat, (opposite.lng - (aspect * (opposite.lat - e.latlng.lat)))]);
        }
        var bounds = new L.LatLngBounds(e.latlng, opposite);
        // Update latlngs by hand to preserve order.
        previous.latlng.update([e.latlng.lat, opposite.lng]);
        next.latlng.update([opposite.lat, e.latlng.lng]);
        this.updateBounds(bounds);
        this.refreshVertexMarkers();
      }
    });
  }
}
