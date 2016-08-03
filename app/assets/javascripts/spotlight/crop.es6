export default class Crop {
  constructor(fileUpload) {
    this.fileUpload = fileUpload;
    this.form = fileUpload.closest('form');
    this.setupAsyncUpload();
    // The input field that stores the IIIF url
    this.iiif_url_field = $(`#${fileUpload.data('url')}`);
    // The hidden input field that stores the association between the parent record
    // and the image.
    this.association = $(`#${fileUpload.data('association')}`);
    this.osdSelector = fileUpload.data('selector');
    if(typeof this.osdSelector === 'undefined')
      console.error(`required attribute data-selector was not provided on #${fileUpload.attr('id')}`)

    this.setupOpenSeadragon(fileUpload.data('tilesource'));
    this.setupFormSubmit();
  }

  setupOpenSeadragon(tileSource) {
    if (tileSource == null)
      return
    this.osdCanvas = new OpenSeadragon({
       id: this.osdSelector,
       preserveViewport: true,
       showNavigationControl: false,
       constrainDuringPan: true,
       tileSources: [tileSource],

       // disable zooming
       gestureSettingsMouse: {
         clickToZoom: false,
         scrollToZoom: false
       },

       // disable panning
       panHorizontal: false,
       panVertical: false

    });

    this.osdCanvas.iiifCrop();
    this.osdCanvas.addHandler('tile-drawn', () => {
      // remove the handler so we only fire on the first instance
      this.osdCanvas.removeHandler('tile-drawn');
      this.applyCurrentRegion();
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
      return this.getDefaultCrop();
    return arr[1].split(',').map((x) => parseInt(x))
  }

  getDefaultCrop() {
    var area = this.fileUpload.data('initial-set-select')
    if (typeof area !== 'undefined')
      return area
    return [0, 0, 1200, 120]
  }

  setupFormSubmit(iiif_url_field) {
    this.form.on('submit', (e) => {
      this.iiif_url_field.val(this.getIiifRegion())
    });
  }

  applyCurrentRegion() {
    var region = this.getRegionFromIiifUrl(this.iiif_url_field.val());
    this.osdCanvas.cropper.setRegion.apply(this.osdCanvas.cropper, region);
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
