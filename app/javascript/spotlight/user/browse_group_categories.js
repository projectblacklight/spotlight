import tns from "tiny-slider"

export default class {
  connect() {
    function itemCount(items, sidebar) {
      if (items < 3) {
        return items
      }
      return sidebar ? 3 : 4
    }

    const containers = document.querySelectorAll(
      "[data-browse-group-categories-carousel]"
    )

    containers.forEach(container => {
      const sidebar = container.dataset.sidebar === "true"
      const items =
        parseInt(container.dataset.browseGroupCategoriesCount, 10) || 0
      const dir = document.documentElement.getAttribute("dir") || "ltr"

      const parent = container.parentElement
      const controls = parent
        ? parent.querySelector(".browse-group-categories-controls")
        : null

      const slider = tns({
        container: container,
        controlsContainer: controls,
        loop: false,
        nav: false,
        items: 1,
        slideBy: "page",
        textDirection: dir,
        responsive: {
          576: {
            items: itemCount(items, sidebar)
          }
        }
      })

      const destroySlider = () => {
        if (slider && typeof slider.destroy === "function") {
          slider.destroy()
        }
        document.removeEventListener("turbolinks:before-cache", destroySlider)
        document.removeEventListener("turbo:before-cache", destroySlider)
      }

      document.addEventListener("turbolinks:before-cache", destroySlider)
      document.addEventListener("turbo:before-cache", destroySlider)
    })
  }
}
