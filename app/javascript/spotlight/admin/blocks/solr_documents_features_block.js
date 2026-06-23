import bootstrap from "bootstrap"

SirTrevor.Blocks.SolrDocumentsFeatures = (function () {
  return SirTrevor.Blocks.SolrDocumentsBase.extend({
    plustextable: false,
    type: "solr_documents_features",

    icon_name: "item_features",

    afterPreviewLoad: function (options) {
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
        } catch (err) {
          // ignore selector errors
        }

        if (!target) {
          target = button.closest(".carousel")
        }

        if (!target || !target.classList.contains("carousel")) return

        const carousel = bootstrap.Carousel.getOrCreateInstance(target)
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
        bootstrap.Carousel.getOrCreateInstance(carouselEl)

        carouselEl
          .querySelectorAll("[data-bs-slide-to]")
          .forEach(function (btn) {
            btn.addEventListener("click", clickHandler)
          })
      })
    }
  })
})()
