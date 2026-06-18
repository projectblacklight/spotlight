// Module to add multi-image selector to widget panels

function initMultiImageSelector(
  panel,
  image_versions,
  clickCallback,
  activeImageId
) {
  const changeLink = document.createElement("a")
  changeLink.href = "javascript:;"
  changeLink.textContent = "Change"

  const thumbsListContainer = document.createElement("div")
  thumbsListContainer.className = "thumbs-list"
  thumbsListContainer.style.display = "none"

  const thumbList = document.createElement("ul")

  const imageIds = (image_versions || []).map(e => e["imageId"])

  init()

  function init() {
    destroyExistingImageSelector()
    if (image_versions && image_versions.length > 1) {
      addChangeLink()
      addThumbsList()
    }
  }

  function addChangeLink() {
    const pagination = panel.querySelector("[data-panel-image-pagination]")
    if (pagination) {
      pagination.innerHTML =
        "Image <span data-current-image='true'>" +
        indexOf(activeImageId) +
        "</span> of " +
        image_versions.length
      pagination.style.display = ""
      pagination.appendChild(document.createTextNode(" "))
      pagination.appendChild(changeLink)
    }
    addChangeLinkBehavior()
  }

  function destroyExistingImageSelector() {
    const pagination = panel.querySelector("[data-panel-image-pagination]")
    if (pagination) {
      pagination.innerHTML = ""
      const nextEl = pagination.nextElementSibling
      if (nextEl && nextEl.classList.contains("thumbs-list")) {
        nextEl.remove()
      }
    }
  }

  function indexOf(thumb) {
    const index = imageIds.indexOf(thumb)
    if (index > -1) {
      return index + 1
    } else {
      return 1
    }
  }

  function addChangeLinkBehavior() {
    changeLink.addEventListener("click", () => {
      if (thumbsListContainer.style.display === "none") {
        thumbsListContainer.style.display = ""
      } else {
        thumbsListContainer.style.display = "none"
      }
      updateThumbListWidth()
      addScrollBehavior()
      scrollToActiveThumb()
      loadVisibleThumbs()
      swapChangeLinkText(changeLink)
    })
  }

  function updateThumbListWidth() {
    let width = 0
    thumbList.querySelectorAll("li").forEach(li => {
      width += li.offsetWidth
    })
    thumbList.style.width = width + 5 + "px"
  }

  function loadVisibleThumbs() {
    const viewportWidth = thumbsListContainer.clientWidth
    let width = 0
    thumbList.querySelectorAll("li").forEach(thisThumb => {
      const image = thisThumb.querySelector("img")
      if (!image) return
      const thumbWidth = thisThumb.offsetWidth
      width += thumbWidth
      const totalWidth = width
      const position = thumbList.offsetLeft + totalWidth - thumbWidth

      if (position >= 0 && position < viewportWidth) {
        const dataSrc = image.dataset.src || image.getAttribute("data-src")
        if (dataSrc) {
          image.src = dataSrc
        }
      }
    })
  }

  let scrollTimeout
  function addScrollBehavior() {
    thumbsListContainer.addEventListener("scroll", () => {
      if (scrollTimeout) {
        clearTimeout(scrollTimeout)
      }
      scrollTimeout = setTimeout(() => {
        loadVisibleThumbs()
      }, 250)
    })
  }

  function scrollToActiveThumb() {
    const halfContainerWidth = thumbsListContainer.clientWidth / 2
    const activeThumb =
      thumbList.querySelector(".active") || thumbList.querySelector("li")
    const activeThumbLeftPosition = activeThumb ? activeThumb.offsetLeft : 0
    const halfActiveThumbWidth = activeThumb ? activeThumb.offsetWidth / 2 : 0

    thumbsListContainer.scrollLeft =
      activeThumbLeftPosition - halfContainerWidth + halfActiveThumbWidth
  }

  function addThumbsList() {
    addThumbsToList()
    updateActiveThumb()
    thumbsListContainer.appendChild(thumbList)
    const cardHeader = panel.querySelector(".card-header")
    if (cardHeader) {
      cardHeader.appendChild(thumbsListContainer)
    }
  }

  function updateActiveThumb() {
    thumbList.querySelectorAll("li").forEach(item => {
      const img = item.querySelector("img")
      if (
        img &&
        (img.dataset.imageId == activeImageId ||
          img.getAttribute("data-image-id") == activeImageId)
      ) {
        item.classList.add("active")
      }
    })
  }

  function swapChangeLinkText(link) {
    link.textContent = link.textContent === "Change" ? "Close" : "Change"
  }

  function addThumbsToList() {
    ;(image_versions || []).forEach((version, i) => {
      const listItem = document.createElement("li")
      listItem.setAttribute("data-index", i.toString())

      const anchor = document.createElement("a")
      anchor.href = "javascript:;"

      const img = document.createElement("img")
      img.src = version["thumb"]
      img.setAttribute("data-image-id", version["imageId"])

      if (version["src"]) {
        img.setAttribute("data-src", version["src"])
      }

      anchor.appendChild(img)
      listItem.appendChild(anchor)

      listItem.addEventListener("click", () => {
        const src = img.getAttribute("src")

        if (typeof clickCallback === "function") {
          clickCallback(version)
        }

        const activeItem = thumbList.querySelector("li.active")
        if (activeItem) {
          activeItem.classList.remove("active")
        }
        listItem.classList.add("active")

        const panelImg = panel.querySelector(".pic img.img-thumbnail")
        if (panelImg) {
          panelImg.setAttribute("src", src)
        }

        const currentImgSpan = panel.querySelector(
          "[data-panel-image-pagination] [data-current-image]"
        )
        if (currentImgSpan) {
          currentImgSpan.textContent = (i + 1).toString()
        }
        scrollToActiveThumb()
      })

      img.addEventListener("load", () => {
        updateThumbListWidth()
      })

      thumbList.appendChild(listItem)
    })
  }
}

export default function multiImageSelector(
  panel,
  image_versions,
  clickCallback,
  activeImageId
) {
  const element = panel && panel.jquery ? panel[0] : panel
  if (!element) return

  initMultiImageSelector(element, image_versions, clickCallback, activeImageId)
}
