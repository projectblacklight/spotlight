import * as bootstrap from "bootstrap"

// Bootstrap's ESM build exports Carousel by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
const Carousel = bootstrap.Carousel ?? bootstrap.default?.Carousel

// Sets up accessible autoplay controls (https://www.w3.org/WAI/ARIA/apg/patterns/carousel/)
const setupAutoplay = function (carouselElement, carousel) {
  const button = carouselElement.querySelector(".carousel-pause-play")
  if (!button) return

  // Turbo restores a cached copy of a page when navigating back, so start
  // from the state the button shows rather than assuming autoplay is on
  let stopped = button.querySelector(".carousel-pause-icon").hidden
  let hovered = false

  const togglePauseButton = function () {
    // Toggle pause/play icon
    button.querySelector(".carousel-pause-icon").hidden = stopped
    button.querySelector(".carousel-play-icon").hidden = !stopped

    // Toggle button aria-label
    button.setAttribute(
      "aria-label",
      stopped ? button.dataset.startLabel : button.dataset.stopLabel,
    )
    // Announce slide changes only when they are not happening automatically
    carouselElement
      .querySelector(".carousel-inner")
      .setAttribute("aria-live", stopped ? "polite" : "off")
  }

  const updateRotation = function () {
    if (stopped || hovered) {
      carousel.pause()
    } else {
      carousel.cycle()
    }
  }

  const toggleAutoplay = function (rotate) {
    stopped = !rotate
    updateRotation()
    togglePauseButton()
  }

  // Stop/start autoplay on button click
  button.addEventListener("click", function () {
    // When play button is clicked, clear any hover so rotation resumes right away
    if (stopped) hovered = false
    toggleAutoplay(stopped)
  })

  // Stop autoplay when keyboard focus moves to anything in the carousel other
  // than the pause/play button
  // Autoplay doesn't restart unless the user explicitly requests it
  carouselElement.addEventListener("focusin", function (event) {
    if (stopped || button.contains(event.target)) return
    toggleAutoplay(false)
  })

  // Mouseover temporarily pauses rotation but does not toggle pause/play button
  carouselElement.addEventListener("mouseenter", function () {
    hovered = true
    updateRotation()
  })

  carouselElement.addEventListener("mouseleave", function () {
    hovered = false
    updateRotation()
  })

  updateRotation()
}

// updates the aria-describedby on the next and prev btns
const updateAriaDescribedBy = function (carouselElement) {
  const items = Array.from(carouselElement.querySelectorAll(".carousel-item"))
  const curIndex = items.findIndex((item) => item.classList.contains("active"))
  const prevIndex = (curIndex - 1 + items.length) % items.length
  const nextIndex = (curIndex + 1) % items.length

  const prevDataId = items[prevIndex]?.dataset.id
  const nextDataId = items[nextIndex]?.dataset.id
  if (prevDataId) {
    carouselElement
      .querySelector(".carousel-control-prev")
      ?.setAttribute("aria-describedby", "carousel-caption-" + prevDataId)
  }
  if (nextDataId) {
    carouselElement
      .querySelector(".carousel-control-next")
      ?.setAttribute("aria-describedby", "carousel-caption-" + nextDataId)
  }
}

export default class {
  connect() {
    if (!Carousel) return

    document.querySelectorAll(".carousel").forEach((carouselElement) => {
      const carousel = Carousel.getOrCreateInstance(carouselElement)

      // on initial page load, set the aria-describedby on the btns for each carousel
      updateAriaDescribedBy(carouselElement)
      setupAutoplay(carouselElement, carousel)

      // on slide change
      carouselElement.addEventListener("slid.bs.carousel", function () {
        updateAriaDescribedBy(carouselElement)
      })
    })
  }
}
