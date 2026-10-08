import OpenSeadragon from "openseadragon"
import * as bootstrap from "bootstrap"

// Bootstrap's ESM build exports Modal by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
const Modal = bootstrap.Modal ?? bootstrap.default?.Modal

// Defined at module scope so that repeated calls to connect() (which runs on
// every turbo:load) register the same listener, which the browser ignores.
function handleClick(e) {
  const zprLink = e.target.closest(".zpr-link")
  if (!zprLink) return

  e.preventDefault()

  const modalElement = document.getElementById("blacklight-modal")
  if (!modalElement) return

  const modalDialog = modalElement.querySelector(".modal-dialog")
  const modalContent = modalDialog
    ? modalDialog.querySelector(".modal-content")
    : null

  if (modalDialog) {
    modalDialog.classList.remove("modal-lg")
    modalDialog.classList.add("modal-xl")
  }

  if (modalContent) {
    modalContent.innerHTML = '<div id="osd-modal-container"></div>'
  }

  const closeText =
    (typeof Spotlight !== "undefined" &&
      Spotlight.ZprLinks &&
      Spotlight.ZprLinks.close) ||
    "Close"
  const zoomInText =
    (typeof Spotlight !== "undefined" &&
      Spotlight.ZprLinks &&
      Spotlight.ZprLinks.zoomIn) ||
    "Zoom in"
  const zoomOutText =
    (typeof Spotlight !== "undefined" &&
      Spotlight.ZprLinks &&
      Spotlight.ZprLinks.zoomOut) ||
    "Zoom out"

  const controls = `<div class="controls d-flex justify-content-center justify-content-md-end">
      <div class="custom-close-controls pe-3 pt-3">
        <button type="button" class="btn btn-dark" data-bs-dismiss="modal" aria-hidden="true">${closeText}</button>
      </div>
      <div class="zoom-controls mb-3 me-md-3">
        <button id="osd-zoom-in" type="button" class="btn btn-dark">${zoomInText}</button>
        <button id="osd-zoom-out" type="button" class="btn btn-dark">${zoomOutText}</button>
      </div>
      <div id="empty-div-required-by-osd"></div>
    </div>`

  const osdModalContainer = document.getElementById("osd-modal-container")
  if (osdModalContainer) {
    const osdDiv = document.createElement("div")
    osdDiv.id = "osd-div"
    osdModalContainer.appendChild(osdDiv)
    osdModalContainer.insertAdjacentHTML("beforeend", controls)
  }

  const modalInstance = Modal.getOrCreateInstance(modalElement)
  modalInstance.show()

  const handleHiddenModal = () => {
    if (modalDialog) {
      modalDialog.classList.remove("modal-xl")
      modalDialog.classList.add("modal-lg")
    }
    modalElement.removeEventListener("hidden.bs.modal", handleHiddenModal)
  }
  modalElement.addEventListener("hidden.bs.modal", handleHiddenModal)

  let tileSource
  const rawSource = zprLink.getAttribute("data-iiif-tilesource") || ""
  try {
    tileSource = JSON.parse(rawSource)
  } catch {
    tileSource = rawSource
  }

  OpenSeadragon({
    id: "osd-div",
    zoomInButton: "osd-zoom-in",
    zoomOutButton: "osd-zoom-out",
    // This is a hack where OpenSeadragon (if using mapped buttons) requires you
    // to map all of the buttons.
    homeButton: "empty-div-required-by-osd",
    fullPageButton: "empty-div-required-by-osd",
    nextButton: "empty-div-required-by-osd",
    previousButton: "empty-div-required-by-osd",
    tileSources: [tileSource],
  })
}

export default class {
  connect() {
    document.addEventListener("click", handleClick)
  }
}
