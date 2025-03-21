export default class Iiif {
  constructor(manifestUrl, manifest) {
    this.manifestUrl = manifestUrl;
    this.manifest = manifest;
  }

  sequences() {
    var it = {};
    var context = this;
    it[Symbol.iterator] = function*() {
      for (let sequence of context.manifest.sequences) {
        yield sequence;
      };
    }
    return it;
  }

  canvases() {
    var it = {};
    var context = this;
    it[Symbol.iterator] = function*() {
      for (let sequence of context.sequences()) {
        for (let canvas of sequence.canvases) {
          yield canvas;
        }
      }
    }
    return it;
  }

  images() {
    var it = {};
    var context = this;
    it[Symbol.iterator] = function*() {
      for (let canvas of context.canvases()) {
        for (let image of canvas.images) {
          var iiifService = image.resource?.service || image.resource?.default?.service;
          var iiifServiceId = iiifService['@id'];
          yield {
            'thumb': iiifServiceId + '/full/!100,100/0/default.jpg',
            'tilesource': iiifServiceId + '/info.json',
            'manifest': context.manifestUrl,
            'canvasId': canvas['@id'],
            'imageId': image['@id']
          };
        }
      }
    }
    return it;
  }

  imagesArray() {
    return Array.from(this.images())
  }
}
