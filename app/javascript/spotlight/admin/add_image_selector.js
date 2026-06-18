import Iiif from "spotlight/admin/iiif"
import multiImageSelector from "spotlight/admin/multi_image_selector"

export function addImageSelector(input, panel, manifestUrl, initialize) {
  if (!manifestUrl) {
    showNonIiifAlert(input)
    return
  }
  var cropper = input.data("iiifCropper")
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
        panel.show()
        multiImageSelector(
          panel,
          thumbs,
          function (selectorImage) {
            cropper.setIiifFields(selectorImage)
          },
          cropper.iiifImageField.val()
        )
      }
    })
}

function showNonIiifAlert(input) {
  input.parent().prev('[data-behavior="non-iiif-alert"]').show()
}

function hideNonIiifAlert(input) {
  input.parent().prev('[data-behavior="non-iiif-alert"]').hide()
}
