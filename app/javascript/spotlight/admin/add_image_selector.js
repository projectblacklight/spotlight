import Iiif from "spotlight/admin/iiif"
import multiImageSelector from "spotlight/admin/multi_image_selector"

export function addImageSelector(input, panel, manifestUrl, initialize) {
  if (!manifestUrl) {
    showNonIiifAlert(input)
    return
  }
  var cropper = input.iiifCropper
  fetch(manifestUrl)
    .then(function (response) {
      return response.json()
    })
    .then(function (manifest) {
      var iiifManifest = new Iiif(manifestUrl, manifest)

      var thumbs = iiifManifest.imagesArray()

      hideNonIiifAlert(input)

      if (initialize) {
        cropper.setIiifFields(thumbs[0])
        multiImageSelector(panel) // Clears out existing selector
      }

      if (thumbs.length > 1) {
        panel.style.display = ""
        multiImageSelector(
          panel,
          thumbs,
          function (selectorImage) {
            cropper.setIiifFields(selectorImage)
          },
          cropper.iiifImageField.value
        )
      }
    })
}

function findNonIiifAlert(input) {
  if (!input || !input.parentElement) return null
  var prev = input.parentElement.previousElementSibling
  if (prev && prev.matches('[data-behavior="non-iiif-alert"]')) {
    return prev
  }
  return null
}

function showNonIiifAlert(input) {
  var alert = findNonIiifAlert(input)
  if (alert) alert.style.display = ""
}

function hideNonIiifAlert(input) {
  var alert = findNonIiifAlert(input)
  if (alert) alert.style.display = "none"
}
