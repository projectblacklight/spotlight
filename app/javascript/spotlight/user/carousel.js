import bootstrap from "bootstrap"

export default class {
  connect() {
    if (bootstrap && bootstrap.Carousel) {
      const carousels = document.querySelectorAll(".carousel")

      // updates the aria-describedby on the next and prev btns
      const updateAriaDescribedBy = function (carouselEl) {
        const activeItem = carouselEl.querySelector(".carousel-item.active")
        if (!activeItem) return

        const items = Array.from(carouselEl.querySelectorAll(".carousel-item"))
        const curIndex = items.indexOf(activeItem)
        if (curIndex === -1) return

        const prevIndex = (curIndex - 1 + items.length) % items.length
        const nextIndex = (curIndex + 1) % items.length

        const prevItem = items[prevIndex]
        const nextItem = items[nextIndex]

        const prevDataId = prevItem ? prevItem.dataset.id : null
        const nextDataId = nextItem ? nextItem.dataset.id : null

        if (prevDataId) {
          const prevControl = carouselEl.querySelector(".carousel-control-prev")
          if (prevControl) {
            prevControl.setAttribute(
              "aria-describedby",
              "carousel-caption-" + prevDataId
            )
          }
        }
        if (nextDataId) {
          const nextControl = carouselEl.querySelector(".carousel-control-next")
          if (nextControl) {
            nextControl.setAttribute(
              "aria-describedby",
              "carousel-caption-" + nextDataId
            )
          }
        }
      }

      // on initial page load, set the aria-describedby on the btns for each carousel
      carousels.forEach(carouselEl => {
        bootstrap.Carousel.getOrCreateInstance(carouselEl)
        updateAriaDescribedBy(carouselEl)

        // on slide change
        carouselEl.addEventListener("slid.bs.carousel", () => {
          updateAriaDescribedBy(carouselEl)
        })
      })
    }
  }
}
