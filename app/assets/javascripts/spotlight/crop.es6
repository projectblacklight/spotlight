export default class Crop {
  constructor(cropArea) {
    this.cropArea = cropArea;
    this.cropArea.data('iiifCropper', this);
    this.cropSelector = '[data-cropper="' + cropArea.data('cropperKey') + '"]';
    this.cropTool = $(this.cropSelector);
    this.formPrefix = this.cropTool.data('form-prefix');
    this.iiifUrlField = $('#' + this.formPrefix + '_iiif_tilesource');
    this.iiifRegionField = $('#' + this.formPrefix + '_iiif_region');
    this.iiifManifestField = $('#' + this.formPrefix + '_iiif_manifest_url');
    this.iiifCanvasField = $('#' + this.formPrefix + '_iiif_canvas_id');
    this.iiifImageField = $('#' + this.formPrefix + '_iiif_image_id');

    this.form = cropArea.closest('form');
    this.initialCropRegion = [0, 0, cropArea.data('crop-width'), cropArea.data('crop-height')];
    this.tileSource = null;

    this.setupAutoCompletes();
    this.setupAjaxFileUpload();
  }

  render() {
    this.setupExistingIiifCropper();
  }

  renderCropArea() {
    if (this.iiifCropper) {
      return;
    }
    this.iiifCropper = L.map(this.cropArea.attr('id'), {
      editable: true,
      center: [0, 0],
      crs: L.CRS.Simple,
      zoom: 0,
      editOptions: {
        rectangleEditorClass: this.aspectRatioPreservingRectangleEditor(parseInt(this.cropArea.data('crop-width')) / parseInt(this.cropArea.data('crop-height')))
      }
    });
    this.invalidateMapSizeOnTabToggle();
  }

  renderCropBox() {
    if (this.iiifCropBox) {
      return;
    }
    var bounds = this.cropRegion();
    this.iiifCropBox = L.rectangle([
      bounds.getNorthWest(), bounds.getSouthEast()
    ]);
    this.iiifCropBox.addTo(this.iiifCropper);
    this.iiifCropBox.enableEdit();
    this.iiifCropBox.on('dblclick', L.DomEvent.stop).on('dblclick', this.iiifCropBox.toggleEdit);
    var self = this;

    this.iiifCropper.on('editable:dragend editable:vertex:dragend', function(e) {
      var bounds = e.layer.getBounds();
      var min = e.target.project(bounds.getNorthWest(), self.maxZoom());
      var max = e.target.project(bounds.getSouthEast(), self.maxZoom());
      var region = [
        Math.max(Math.round(min.x), 0),
        Math.max(Math.round(min.y), 0),
        Math.round(max.x - min.x),
        Math.round(max.y - min.y)
      ];

      self.iiifRegionField.val(region.join(','));
    });
  }

  maxZoom() {
    if(this.iiifLayer) {
      return this.iiifLayer.maxZoom;
    }
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
    } else if(this.previousCropBox) {
      this.previousCropBox.remove();
    }

    this.tileSource = source;
    this.iiifUrlField.val(source);
    this.loaded = false;
    this.setupIiifCropper();
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

  // Setup the cropper on page load if the field
  // that holds the IIIF url is populated
  setupExistingIiifCropper() {
    if(this.iiifUrlField.val() === '') {
      return;
    }

    this.addImageSelectorToExistingCropTool();
    this.setTileSource(this.iiifUrlField.val());
  }

  addImageSelectorToExistingCropTool() {
    if(this.iiifManifestField.val() === '') {
      return;
    }

    var input = $('[data-behavior="autocomplete"]', this.cropTool);
    var panel = $(input.data('target-panel'));
    // This is defined in search_typeahead.js
    addImageSelector(input, panel, this.iiifManifestField.val(), !this.iiifImageField.val());
  }

  setupIiifCropper() {
    if (this.tileSource === null || this.tileSource === undefined) {
      console.error('No tilesource provided when setting up IIIF Cropper');
      return;
    }

    this.renderCropArea();

    if(this.iiifLayer) {
      this.iiifCropper.removeLayer(this.iiifLayer);
    }

    this.iiifLayer = L.tileLayer.iiif(this.tileSource, {
      tileSize: 512
    }).addTo(this.iiifCropper);

    this.positionIiifCropBox();

    this.cropArea.data('initiallyVisible', this.cropArea.is(':visible'));
  }

  positionIiifCropBox(region) {
    var self = this;
    this.iiifLayer.on('load', function() {
      if (!self.loaded) {
        var bounds = self.cropRegion();
        self.renderCropBox();
        self.iiifCropper.panTo(bounds.getCenter());
        self.iiifCropBox.setBounds(bounds);
        self.iiifCropBox.editor.editLayer.clearLayers();
        self.iiifCropBox.editor.refresh();
        self.iiifCropBox.editor.initVertexMarkers();
        self.loaded = true;
      }
    });
  }

  cropRegion() {
    var regionFieldValue = this.iiifRegionField.val();
    var b;
    if(!regionFieldValue || regionFieldValue === '') {
      b = this.initialCropRegion;
    } else {
      b = regionFieldValue.split(',');
    }

    var minPoint = L.point(parseInt(b[0]), parseInt(b[1]));
    var maxPoint = L.point(parseInt(b[0]) + parseInt(b[2]), parseInt(b[1]) + parseInt(b[3]));

    var min = this.iiifCropper.unproject(minPoint, this.maxZoom());
    var max = this.iiifCropper.unproject(maxPoint, this.maxZoom());
    var bounds = L.latLngBounds(min, max);
    return bounds;
  }

  invalidateMapSizeOnTabToggle() {
    var tabs = $('[role="tablist"]', this.form);
    var self = this;
    tabs.on('shown.bs.tab', function() {
      if(self.cropArea.data('initiallyVisible') === false && self.cropArea.is(':visible')) {
        self.iiifCropper.invalidateSize();
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
      //Options to tell jQuery not to process data or worry about content-type.
      cache: false,
      contentType: false,
      processData: false
    });
  }

  successHandler(data, stat, xhr) {
    this.setIiifFields({ tilesource: data.tilesource });
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
