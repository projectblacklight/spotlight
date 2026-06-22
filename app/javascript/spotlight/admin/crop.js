import { addImageSelector } from "spotlight/admin/add_image_selector"
import Core from "spotlight/core"

export default class Crop {
  constructor(cropArea, preserveAspectRatio = true) {
    // Extract raw DOM element if cropArea is a jQuery object
    this.cropArea = cropArea && cropArea.jquery ? cropArea[0] : cropArea
    if (this.cropArea) {
      this.cropArea.iiifCropper = this
    }

    // Get the cropper key and find the crop tool element
    const cropperKey = this.cropArea
      ? this.cropArea.dataset.cropperKey ||
        this.cropArea.getAttribute("data-cropper-key")
      : null
    this.cropSelector = '[data-cropper="' + cropperKey + '"]'
    this.cropTool = document.querySelector(this.cropSelector)

    // Exhibit and masthead cropping requires the ratio between image width and height
    // to be consistent, whereas item widget cropping allows any combination of
    // image width and height.
    this.preserveAspectRatio = preserveAspectRatio

    // Get the IIIF input elements used to store/reference IIIF information
    this.inputPrefix = this.cropTool
      ? this.cropTool.dataset.inputPrefix ||
        this.cropTool.getAttribute("data-input-prefix")
      : null
    this.iiifUrlField = this.iiifInputElement(
      this.inputPrefix,
      "iiif_tilesource",
      this.cropTool
    )
    this.iiifRegionField = this.iiifInputElement(
      this.inputPrefix,
      "iiif_region",
      this.cropTool
    )
    this.iiifManifestField = this.iiifInputElement(
      this.inputPrefix,
      "iiif_manifest_url",
      this.cropTool
    )
    this.iiifCanvasField = this.iiifInputElement(
      this.inputPrefix,
      "iiif_canvas_id",
      this.cropTool
    )
    this.iiifImageField = this.iiifInputElement(
      this.inputPrefix,
      "iiif_image_id",
      this.cropTool
    )

    // Get the closest form element
    this.form = this.cropArea ? this.cropArea.closest("form") : null
    this.tileSource = null
  }

  // Return the iiif input element based on the fieldname.
  // Multiple input fields with the same name on the page may be related
  // to a cropper. We thus need to pass in a parent element.
  iiifInputElement(inputPrefix, fieldName, inputParentElement) {
    if (inputParentElement && inputPrefix) {
      const selector = 'input[name="' + inputPrefix + "[" + fieldName + ']"]'
      const element = inputParentElement.querySelector(selector)
      if (element) {
        if (!element.val) {
          element.val = function (value) {
            if (value === undefined) {
              return this.value
            } else {
              this.value = value
              return this
            }
          }
        }
        return element
      }
    }
    // Return a dummy object to prevent null-pointer exceptions
    return {
      value: undefined,
      val: function (value) {
        if (value === undefined) return undefined
        return this
      }
    }
  }

  // Render the cropper environment and add hooks into the autocomplete and upload forms
  render() {
    this.setupAutoCompletes()
    this.setupAjaxFileUpload()
    this.setupExistingIiifCropper()
  }

  // Setup the cropper on page load if the field
  // that holds the IIIF url is populated
  setupExistingIiifCropper() {
    if (this.iiifUrlField.val() === "") {
      return
    }

    this.addImageSelectorToExistingCropTool()
    this.setTileSource(this.iiifUrlField.val())
  }

  // Display the IIIF Cropper map with the current IIIF Layer (and cropbox, once the layer is available)
  setupIiifCropper() {
    this.loaded = false

    this.renderCropperMap()

    if (this.imageLayer) {
      // Force a broken layer's container to be an element before removing.
      // Code in leaflet-iiif land calls delete on the image layer's container when removing,
      // which errors if there is an issue fetching the info.json and stops further necessary steps to execute.
      if (!this.imageLayer._container) {
        this.imageLayer._container = document.createElement("div")
      }
      this.cropperMap.removeLayer(this.imageLayer)
    }

    this.imageLayer = L.tileLayer.iiif(this.tileSource).addTo(this.cropperMap)

    var self = this
    this.imageLayer.on("load", function () {
      if (!self.loaded) {
        var region = self.getCropRegion()
        self.positionIiifCropBox(region)
        self.loaded = true
      }
    })

    this.cropAreaInitiallyVisible = this.isCropAreaVisible()
  }

  isCropAreaVisible() {
    if (!this.cropArea) return false
    return !!(
      this.cropArea.offsetWidth ||
      this.cropArea.offsetHeight ||
      this.cropArea.getClientRects().length
    )
  }

  // Get (or initialize) the current crop region from the form data
  getCropRegion() {
    var regionFieldValue = this.iiifRegionField.val()
    if (!regionFieldValue || regionFieldValue === "") {
      var region = this.defaultCropRegion()
      this.iiifRegionField.val(region)
      return region
    } else {
      return regionFieldValue.split(",")
    }
  }

  // Calculate a default crop region in the center of the image using the correct aspect ratio
  defaultCropRegion() {
    var imageWidth = this.imageLayer.x
    var imageHeight = this.imageLayer.y

    var boxWidth = Math.floor(imageWidth / 2)
    var boxHeight = Math.floor(boxWidth / this.aspectRatio())

    return [
      Math.floor((imageWidth - boxWidth) / 2),
      Math.floor((imageHeight - boxHeight) / 2),
      boxWidth,
      boxHeight
    ]
  }

  // Calculate the required aspect ratio for the crop area
  aspectRatio() {
    if (!this.cropArea) return 1
    var cropWidth = parseInt(
      this.cropArea.dataset.cropWidth ||
        this.cropArea.getAttribute("data-crop-width")
    )
    var cropHeight = parseInt(
      this.cropArea.dataset.cropHeight ||
        this.cropArea.getAttribute("data-crop-height")
    )
    return cropWidth / cropHeight
  }

  // Position the IIIF Crop Box at the given IIIF region
  positionIiifCropBox(region) {
    var bounds = this.unprojectIIIFRegionToBounds(region)

    if (!this.cropBox) {
      this.renderCropBox(bounds)
    }

    this.cropBox.setBounds(bounds)
    this.cropperMap.invalidateSize()
    this.cropperMap.fitBounds(bounds)

    this.cropBox.editor.editLayer.clearLayers()
    this.cropBox.editor.refresh()
    this.cropBox.editor.initVertexMarkers()
  }

  // Set all of the various input fields to
  // the appropriate IIIF URL or identifier
  setIiifFields(iiifObject) {
    this.setTileSource(iiifObject.tilesource)
    this.iiifManifestField.val(iiifObject.manifest)
    this.iiifCanvasField.val(iiifObject.canvasId)
    this.iiifImageField.val(iiifObject.imageId)
  }

  // Set the Crop tileSource and setup the cropper
  setTileSource(source) {
    if (source == this.tileSource) {
      return
    }

    if (source === null || source === undefined) {
      console.error("No tilesource provided when setting up IIIF Cropper")
      return
    }

    if (this.cropBox) {
      this.iiifRegionField.val("")
    }

    this.tileSource = source
    this.iiifUrlField.val(source)
    this.setupIiifCropper()
  }

  // Render the Leaflet Map into the crop area
  renderCropperMap() {
    if (this.cropperMap || !this.cropArea) {
      return
    }

    var cropperOptions = {
      editable: true,
      center: [0, 0],
      crs: L.CRS.Simple,
      zoom: 0
    }

    if (this.preserveAspectRatio) {
      cropperOptions["editOptions"] = {
        rectangleEditorClass: this.aspectRatioPreservingRectangleEditor(
          this.aspectRatio()
        )
      }
    }

    this.cropperMap = L.map(
      this.cropArea.getAttribute("id") || this.cropArea.id,
      cropperOptions
    )
    this.invalidateMapSizeOnTabToggle()
  }

  // Render the crop box (a Leaflet editable rectangle) onto the canvas
  renderCropBox(initialBounds) {
    this.cropBox = L.rectangle(initialBounds)
    this.cropBox.addTo(this.cropperMap)
    this.cropBox.enableEdit()
    this.cropBox
      .on("dblclick", L.DomEvent.stop)
      .on("dblclick", this.cropBox.toggleEdit)

    var self = this
    this.cropperMap.on(
      "editable:dragend editable:vertex:dragend",
      function (e) {
        var bounds = e.layer.getBounds()
        var region = self.projectBoundsToIIIFRegion(bounds)

        self.iiifRegionField.val(region.join(","))
      }
    )
  }

  // Get the maximum zoom level for the IIIF Layer (always 1:1 image pixel to canvas?)
  maxZoom() {
    if (this.imageLayer) {
      return this.imageLayer.maxZoom
    }
  }

  // Take a Leaflet LatLngBounds object and transform it into a IIIF [x, y, w, h] region
  projectBoundsToIIIFRegion(bounds) {
    var min = this.cropperMap.project(bounds.getNorthWest(), this.maxZoom())
    var max = this.cropperMap.project(bounds.getSouthEast(), this.maxZoom())
    return [
      Math.max(Math.floor(min.x), 0),
      Math.max(Math.floor(min.y), 0),
      Math.floor(max.x - min.x),
      Math.floor(max.y - min.y)
    ]
  }

  // Take a IIIF [x, y, w, h] region and transform it into a Leaflet LatLngBounds
  unprojectIIIFRegionToBounds(region) {
    var minPoint = L.point(parseInt(region[0]), parseInt(region[1]))
    var maxPoint = L.point(
      parseInt(region[0]) + parseInt(region[2]),
      parseInt(region[1]) + parseInt(region[3])
    )

    var min = this.cropperMap.unproject(minPoint, this.maxZoom())
    var max = this.cropperMap.unproject(maxPoint, this.maxZoom())
    return L.latLngBounds(min, max)
  }

  // TODO: Add accessors to update hidden inputs with IIIF uri/ids?

  // Setup autocomplete inputs to have the iiif_cropper context
  setupAutoCompletes() {
    if (!this.cropTool) return
    var input = this.cropTool.querySelector('[data-behavior="autocomplete"]')
    if (input) {
      input.iiifCropper = this
    }
  }

  setupAjaxFileUpload() {
    if (!this.cropTool) return
    this.fileInput = this.cropTool.querySelector('input[type="file"]')
    if (this.fileInput) {
      this.fileInput.addEventListener("change", () => this.uploadFile())
    }
  }

  addImageSelectorToExistingCropTool() {
    if (this.iiifManifestField.val() === "") {
      return
    }

    if (!this.cropTool) {
      return
    }

    var inputElement = this.cropTool.querySelector(
      '[data-behavior="autocomplete"]'
    )

    // Not every page which uses this module has autocomplete linked directly to the cropping tool
    if (inputElement) {
      var targetPanel =
        inputElement.dataset.targetPanel ||
        inputElement.getAttribute("data-target-panel")
      var panelElement = document.querySelector(targetPanel)
      if (panelElement) {
        addImageSelector(
          inputElement,
          panelElement,
          this.iiifManifestField.val(),
          !this.iiifImageField.val()
        )
      }
    }
  }

  invalidateMapSizeOnTabToggle() {
    if (!this.form) return
    var tabs = this.form.querySelectorAll('[role="tablist"]')
    var self = this
    var onTabShown = function () {
      if (self.cropAreaInitiallyVisible === false && self.isCropAreaVisible()) {
        self.cropperMap.invalidateSize()
        // Because the map size is 0,0 when image is loading (not visible) we need to refit the bounds of the layer
        self.imageLayer._fitBounds()
        self.cropAreaInitiallyVisible = null
      }
    }

    tabs.forEach(tab => {
      tab.addEventListener("shown.bs.tab", onTabShown)
    })
  }

  // Get all the form data with the exception of the _method field.
  getData() {
    if (!this.form) return null
    var data = new FormData(this.form)
    data.append("_method", null)
    return data
  }

  uploadFile() {
    if (!this.fileInput) return
    var url =
      this.fileInput.dataset.endpoint ||
      this.fileInput.getAttribute("data-endpoint")
    // Every post creates a new image/masthead.
    // Because they create IIIF urls which are heavily cached.
    fetch(url, {
      method: "POST",
      headers: {
        "X-CSRF-Token": Core.csrfToken() || "",
        Accept: "application/json"
      },
      body: this.getData()
    })
      .then(response => {
        if (!response.ok) {
          return response.json().then(
            json => {
              var fakeXhr = { responseJSON: json }
              this.errorHandler(fakeXhr, "error", response.statusText)
            },
            () => {
              this.errorHandler({}, "error", "Upload failed")
            }
          )
        }
        return response.json()
      })
      .then(data => {
        if (data) {
          this.successHandler(data, "success", null)
        }
      })
      .catch(error => {
        this.errorHandler({}, "error", error.message)
      })
  }

  successHandler(data, stat, xhr) {
    this.setIiifFields({ tilesource: data.tilesource })
    this.setUploadId(data.id)
    this.clearUploadErrors()
  }

  errorHandler(xhr, stat, error) {
    let errorMessage = "Upload failed"
    if (xhr.responseJSON) {
      if (xhr.responseJSON.errors) {
        errorMessage = xhr.responseJSON.errors.join(", ")
      } else if (xhr.responseJSON.error) {
        errorMessage = xhr.responseJSON.error
      }
    }
    this.showUploadError(errorMessage)
  }

  getUploadErrorsElement() {
    if (!this.cropTool) return null
    return this.cropTool.querySelector(".featured-image.invalid-feedback")
  }

  showUploadError(errorMessage) {
    const errorsElement = this.getUploadErrorsElement()
    if (errorsElement) {
      errorsElement.textContent = errorMessage
      errorsElement.style.display = "block"
    } else {
      console.error("uploadFile", errorMessage)
    }
  }

  clearUploadErrors() {
    const errorsElement = this.getUploadErrorsElement()
    if (errorsElement) {
      errorsElement.textContent = ""
      errorsElement.style.display = "none"
    }
  }

  setUploadId(id) {
    // This input is currently used for exhibit masthead or thumbnail image upload.
    // The name should be sufficient in this case, as we don't use this part of the
    // code for solr document widgets where we enable cropping.
    // If we require more specificity, we can scope this to this.cropTool.
    const selector = 'input[name="' + this.inputPrefix + '[upload_id]"]'
    const element = document.querySelector(selector)
    if (element) {
      element.value = id
    }
  }

  aspectRatioPreservingRectangleEditor(aspect) {
    return L.Editable.RectangleEditor.extend({
      extendBounds: function (e) {
        var index = e.vertex.getIndex(),
          next = e.vertex.getNext(),
          previous = e.vertex.getPrevious(),
          oppositeIndex = (index + 2) % 4,
          opposite = e.vertex.latlngs[oppositeIndex]

        if (index % 2 == 1) {
          // calculate horiz. displacement
          e.latlng.update([
            opposite.lat + (1 / aspect) * (opposite.lng - e.latlng.lng),
            e.latlng.lng
          ])
        } else {
          // calculate vert. displacement
          e.latlng.update([
            e.latlng.lat,
            opposite.lng - aspect * (opposite.lat - e.latlng.lat)
          ])
        }
        var bounds = new L.LatLngBounds(e.latlng, opposite)
        // Update latlngs by hand to preserve order.
        previous.latlng.update([e.latlng.lat, opposite.lng])
        next.latlng.update([opposite.lat, e.latlng.lng])
        this.updateBounds(bounds)
        this.refreshVertexMarkers()
      }
    })
  }
}
