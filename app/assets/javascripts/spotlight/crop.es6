export default class Crop {
  constructor(fileUpload) {
    this.fileUpload = fileUpload;
    this.form = fileUpload.closest('form');
    this.setupAsyncUpload();
    var iiif_url_field = $(`#${fileUpload.data('url')}`);

    this.region = this.getRegionFromIiifUrl(iiif_url_field.val());
    this.association = $(`#${fileUpload.data('association')}`);
    this.osdSelector = fileUpload.data('selector');
    this.setupOpenSeadragon(fileUpload.data('tilesource'));
    this.setupFormSubmit(iiif_url_field);
  }

  setupOpenSeadragon(tileSource) {
    if (tileSource == null)
      return
    this.osdCanvas = new OpenSeadragon({
       id: this.osdSelector,
       preserveViewport: true,
       showNavigationControl: false,
       constrainDuringPan: true,
       tileSources: [tileSource]
    });
    this.osdCanvas.iiifCrop();
    this.osdCanvas.addHandler('tile-drawn', () => {
      // remove the handler so we only fire on the first instance
      this.osdCanvas.removeHandler('tile-drawn');
      this.osdCanvas.cropper.setRegion.apply(this.osdCanvas.cropper, this.region);
    });
    this.osdCanvas.cropper.lockAspectRatio()
    xosd = this.osdCanvas; // for debugging, remove.
  }

  setupAsyncUpload() {
    this.fileUpload.change(() => this.uploadFile());
  }

  // Grab a region from a IIIF url
  getRegionFromIiifUrl(url) {
    var re = /https?:\/\/[^/]*\/[^/]*\/[^/]*\/([^/]*)\//
    var arr = re.exec(url)
    if (arr == null)
      return [0, 0, 1200, 120]
    return arr[1].split(',').map((x) => parseInt(x))
  }

  setupFormSubmit(iiif_url_field) {
    this.form.on('submit', (e) => {
      iiif_url_field.val(this.getIiifRegion())
    });
  }

  getIiifRegion() {
    if (!this.osdCanvas || !this.osdCanvas.viewport) {
      return null
    }
    return this.osdCanvas.cropper.getIiifSelection().getUrl('600,');
  }

  // Get all the form data with the exception of the _method field.
  getData() {
    var data = new FormData(this.form[0]);
    data.append('_method', null);
    return data;
  }

  uploadFile() {
    var url = this.fileUpload.data('endpoint')
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
    // if this is the first image added, setup OSD
    if (this.osdCanvas) {
      this.osdCanvas.open(data.tilesource);
    } else {
      this.setupOpenSeadragon(data.tilesource)
    }
    this.association.val(data.id);
  }
}
