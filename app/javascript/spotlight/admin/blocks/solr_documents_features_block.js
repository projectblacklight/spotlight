import * as bootstrap from "bootstrap"

// Bootstrap's ESM build exports Carousel by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
const Carousel = bootstrap.Carousel ?? bootstrap.default?.Carousel

SirTrevor.Blocks.SolrDocumentsFeatures = (function () {
  return SirTrevor.Blocks.SolrDocumentsBase.extend({
    plustextable: false,
    type: "solr_documents_features",

    icon_name: "item_features",

    afterPreviewLoad: function (_options) {
      const carousels = this.inner.querySelectorAll(".carousel")

      const clickHandler = function (e) {
        const button = e.currentTarget
        let target
        try {
          const targetSelector =
            button.getAttribute("data-bs-target") || button.getAttribute("href")
          if (targetSelector) {
            target = document.querySelector(targetSelector)
          }
        } catch {
          // ignore selector errors
        }

        if (!target) {
          target = button.closest(".carousel")
        }

        if (!target || !target.classList.contains("carousel")) return

        const carousel = Carousel.getOrCreateInstance(target)
        const slideIndex = button.getAttribute("data-bs-slide-to")

        if (slideIndex !== null) {
          carousel.to(parseInt(slideIndex, 10))
        } else {
          const slideAction = button.getAttribute("data-bs-slide")
          if (slideAction === "next") {
            carousel.next()
          } else if (slideAction === "prev") {
            carousel.prev()
          }
        }

        e.preventDefault()
      }

      carousels.forEach(function (carouselEl) {
        Carousel.getOrCreateInstance(carouselEl)

        carouselEl
          .querySelectorAll("[data-bs-slide-to]")
          .forEach(function (btn) {
            btn.addEventListener("click", clickHandler)
          })
      })
    },
  })
})()
