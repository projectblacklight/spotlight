import * as bootstrap from "bootstrap"

// Bootstrap's ESM build exports Carousel by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
const Carousel = bootstrap.Carousel ?? bootstrap.default?.Carousel

// Sets up accessible autoplay controls (https://www.w3.org/WAI/ARIA/apg/patterns/carousel/)
const setupAutoplay = function (carouselElement) {
  const button = carouselElement.querySelector(".carousel-pause-play")
  if (!button) return

  const carousel = Carousel.getInstance(carouselElement)
  let stopped = false
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

export default class {
  connect() {
    if ($.fn.carousel) {
      const $carousel = $(".carousel")

      // updates the aria-describedby on the next and prev btns
      const updateAriaDescribedBy = function ($carousel) {
        const $activeItem = $carousel.find(".carousel-item.active")
        const $items = $carousel.find(".carousel-item")
        const curIndex = $items.index($activeItem)
        const prevIndex = (curIndex - 1 + $items.length) % $items.length
        const nextIndex = (curIndex + 1) % $items.length

        const prevDataId = $items.eq(prevIndex).data("id")
        const nextDataId = $items.eq(nextIndex).data("id")
        if (prevDataId) {
          $carousel
            .find(".carousel-control-prev")
            .attr("aria-describedby", "carousel-caption-" + prevDataId)
        }
        if (nextDataId) {
          $carousel
            .find(".carousel-control-next")
            .attr("aria-describedby", "carousel-caption-" + nextDataId)
        }
      }

      // on initial page load, set the aria-describedby on the btns for each carousel
      $carousel.each(function () {
        const $this = $(this)
        $this.carousel()
        updateAriaDescribedBy($this)
        setupAutoplay(this)
      })

      // on slide change
      $carousel.on("slid.bs.carousel", function () {
        updateAriaDescribedBy($(this))
      })
    }
  }
}
