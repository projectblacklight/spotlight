import Crop from "spotlight/admin/crop"

export default class CroppableModal {
  attachModalHandlers() {
    // Attach handler for when modal first loads, to show the cropper
    this.attachModalLoadBehavior()
    // Attach handler for save by checking if clicking in the modal is on a save button
    this.attachModalSaveHandler()
  }

  attachModalLoadBehavior() {
    // Listen for event thrown when modal is displayed with content
    document.addEventListener(
      "loaded.blacklight.blacklight-modal",
      function (e) {
        const dataCropperDiv = document.querySelector(
          '#blacklight-modal [data-behavior="iiif-cropper"]'
        )

        if (dataCropperDiv) {
          new Crop(dataCropperDiv, false).render()
        }
      }
    )
  }

  // Field names are of the format item[item_0][iiif_image_id]
  iiifInputField(itemIndex, fieldName, parentElement) {
    const itemPrefix = "item[" + itemIndex + "]"
    const selector = 'input[name="' + itemPrefix + "[" + fieldName + ']"]'
    return parentElement ? parentElement.querySelector(selector) : null
  }

  attachModalSaveHandler() {
    const context = this

    document.addEventListener("show.blacklight.blacklight-modal", function (e) {
      const saveBtn = document.getElementById("save-cropping-selection")
      if (saveBtn) {
        saveBtn.addEventListener("click", () => {
          context.saveCroppedRegion()
        })
      }
    })
  }

  saveCroppedRegion() {
    //On hitting "save changes", we need to copy over the value
    //to the iiif thumbnail url input field as well as the image source itself
    const context = this
    const dataCropperDiv = document.querySelector(
      '#blacklight-modal [data-behavior="iiif-cropper"]'
    )

    if (dataCropperDiv) {
      const dataCropperKey =
        dataCropperDiv.dataset.cropperKey ||
        dataCropperDiv.getAttribute("data-cropper-key")
      const itemIndex =
        dataCropperDiv.dataset.indexId ||
        dataCropperDiv.getAttribute("data-index-id")

      // Get the element on the main edit page whose select image link opened up the modal
      const itemElement = document.querySelector(
        '[data-cropper="' + dataCropperKey + '"]'
      )
      if (!itemElement) return

      // Get the hidden input field on the main edit page corresponding to this item
      const thumbnailSaveField = context.iiifInputField(
        itemIndex,
        "thumbnail_image_url",
        itemElement
      )
      const fullimageSaveField = context.iiifInputField(
        itemIndex,
        "full_image_url",
        itemElement
      )

      const iiifTilesourceField = context.iiifInputField(
        itemIndex,
        "iiif_tilesource",
        itemElement
      )
      const regionValueField = context.iiifInputField(
        itemIndex,
        "iiif_region",
        itemElement
      )

      const iiifTilesource = iiifTilesourceField
        ? iiifTilesourceField.value
        : ""
      const regionValue = regionValueField ? regionValueField.value : ""

      // Extract the region string to incorporate into the thumbnail URL
      const lastIndex = iiifTilesource.lastIndexOf("/info.json")
      const urlPrefix =
        lastIndex !== -1
          ? iiifTilesource.substring(0, lastIndex)
          : iiifTilesource
      const thumbnailUrl =
        urlPrefix + "/" + regionValue + "/!400,400/0/default.jpg"

      // Set the hidden input value to the thumbnail URL
      // Also set the full image - which is used by widgets like carousel or slideshow
      if (thumbnailSaveField) {
        thumbnailSaveField.value = thumbnailUrl
        thumbnailSaveField.dispatchEvent(new Event("change", { bubbles: true }))
      }
      if (fullimageSaveField) {
        fullimageSaveField.value =
          urlPrefix + "/" + regionValue + "/!800,800/0/default.jpg"
        fullimageSaveField.dispatchEvent(new Event("change", { bubbles: true }))
      }

      // Also change img url for thumbnail image
      const itemImage = itemElement.querySelector("img.img-thumbnail")
      if (itemImage) {
        itemImage.setAttribute("src", thumbnailUrl)
      }
    }
  }
}
