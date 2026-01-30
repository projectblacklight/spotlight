import Iiif from "spotlight/admin/iiif"

export function addImageSelector(input, panel, manifestUrl, initialize) {
  if (!manifestUrl) {
    showNonIiifAlert(input)
    return
  }

  // Get the cropper from the input element's data
  let cropper = input.dataset.iiifCropper
  if (typeof cropper === "string") {
    try {
      cropper = JSON.parse(cropper)
    } catch (e) {
      // Handle parsing error if needed
    }
  }

  // Use fetch instead of $.ajax
  fetch(manifestUrl)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`)
      }
      return response.json()
    })
    .then(manifest => {
      const iiifManifest = new Iiif(manifestUrl, manifest)
      const thumbs = iiifManifest.imagesArray()

      hideNonIiifAlert(input)

      if (initialize) {
        cropper.setIiifFields(thumbs[0])

        // Assuming multiImageSelector is a custom function that needs to be called on panel
        if (typeof panel.multiImageSelector === "function") {
          panel.multiImageSelector() // Clears out existing selector
        } else {
          // If panel is a DOM element and not a custom object
          const multiImageSelector = panel.querySelector(
            '[data-behavior="multi-image-selector"]'
          )
          if (multiImageSelector) {
            // Clear the selector
            multiImageSelector.innerHTML = ""
          }
        }
      }

      if (thumbs.length > 1) {
        // Show panel
        panel.style.display = "block"

        // Call multiImageSelector with parameters
        if (typeof panel.multiImageSelector === "function") {
          panel.multiImageSelector(
            thumbs,
            function (selectorImage) {
              cropper.setIiifFields(selectorImage)
            },
            cropper.iiifImageField.value
          )
        } else {
          // If panel is a DOM element, implement the selector functionality
          const multiImageSelector = panel.querySelector(
            '[data-behavior="multi-image-selector"]'
          )
          if (multiImageSelector) {
            createMultiImageSelector(
              multiImageSelector,
              thumbs,
              function (selectorImage) {
                cropper.setIiifFields(selectorImage)
              },
              cropper.iiifImageField.value
            )
          }
        }
      }
    })
    .catch(error => {
      console.error("Error fetching manifest:", error)
    })
}

function showNonIiifAlert(input) {
  const alert = input.parentNode.previousElementSibling
  if (alert && alert.dataset.behavior === "non-iiif-alert") {
    alert.style.display = "block"
  }
}

function hideNonIiifAlert(input) {
  const alert = input.parentNode.previousElementSibling
  if (alert && alert.dataset.behavior === "non-iiif-alert") {
    alert.style.display = "none"
  }
}

// Helper function to implement multiImageSelector functionality
function createMultiImageSelector(container, thumbs, callback, selectedValue) {
  // Clear existing content
  container.innerHTML = ""

  // Create image selector elements
  thumbs.forEach(thumb => {
    const imgElement = document.createElement("img")
    imgElement.src = thumb.thumbnail || thumb.url
    imgElement.alt = thumb.label || ""
    imgElement.classList.add("iiif-image")

    // Add selected class if this is the selected value
    if (
      selectedValue &&
      (selectedValue === thumb.id || selectedValue === thumb.url)
    ) {
      imgElement.classList.add("selected")
    }

    imgElement.addEventListener("click", function () {
      // Remove selected class from all images
      container.querySelectorAll(".iiif-image").forEach(img => {
        img.classList.remove("selected")
      })

      // Add selected class to clicked image
      imgElement.classList.add("selected")

      // Call the callback with the selected image data
      callback(thumb)
    })

    container.appendChild(imgElement)
  })
}
