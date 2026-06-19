(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory(require('bootstrap'), require('openseadragon'), require('sir-trevor'), require('sortablejs'), require('@hotwired/stimulus')) :
  typeof define === 'function' && define.amd ? define(['bootstrap', 'openseadragon', 'sir-trevor', 'sortablejs', '@hotwired/stimulus'], factory) :
  (global = typeof globalThis !== 'undefined' ? globalThis : global || self, global.Spotlight = factory(global.bootstrap, global.OpenSeadragon, global.SirTrevor, global.Sortable, global.Stimulus));
})(this, (function (bootstrap, OpenSeadragon, SirTrevor$1, Sortable, stimulus) { 'use strict';

  function _interopNamespaceDefault(e) {
    const n = Object.create(null, { [Symbol.toStringTag]: { value: 'Module' } });
    if (e) {
      for (const k in e) {
        if (k !== 'default') {
          const d = Object.getOwnPropertyDescriptor(e, k);
          Object.defineProperty(n, k, d.get ? d : {
            enumerable: true,
            get: () => e[k]
          });
        }
      }
    }
    n.default = e;
    return Object.freeze(n);
  }

  const bootstrap__namespace = /*#__PURE__*/_interopNamespaceDefault(bootstrap);

  // Bootstrap's ESM build exports Carousel by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
  const Carousel$2 = bootstrap__namespace.Carousel ?? bootstrap__namespace.default?.Carousel;

  // Sets up accessible autoplay controls (https://www.w3.org/WAI/ARIA/apg/patterns/carousel/)
  const setupAutoplay = function (carouselElement, carousel) {
    const button = carouselElement.querySelector(".carousel-pause-play");
    if (!button) return

    // Turbo restores a cached copy of a page when navigating back, so start
    // from the state the button shows rather than assuming autoplay is on
    let stopped = button.querySelector(".carousel-pause-icon").hidden;
    let hovered = false;

    const togglePauseButton = function () {
      // Toggle pause/play icon
      button.querySelector(".carousel-pause-icon").hidden = stopped;
      button.querySelector(".carousel-play-icon").hidden = !stopped;

      // Toggle button aria-label
      button.setAttribute(
        "aria-label",
        stopped ? button.dataset.startLabel : button.dataset.stopLabel,
      );
      // Announce slide changes only when they are not happening automatically
      carouselElement
        .querySelector(".carousel-inner")
        .setAttribute("aria-live", stopped ? "polite" : "off");
    };

    const updateRotation = function () {
      if (stopped || hovered) {
        carousel.pause();
      } else {
        carousel.cycle();
      }
    };

    const toggleAutoplay = function (rotate) {
      stopped = !rotate;
      updateRotation();
      togglePauseButton();
    };

    // Stop/start autoplay on button click
    button.addEventListener("click", function () {
      // When play button is clicked, clear any hover so rotation resumes right away
      if (stopped) hovered = false;
      toggleAutoplay(stopped);
    });

    // Stop autoplay when keyboard focus moves to anything in the carousel other
    // than the pause/play button
    // Autoplay doesn't restart unless the user explicitly requests it
    carouselElement.addEventListener("focusin", function (event) {
      if (stopped || button.contains(event.target)) return
      toggleAutoplay(false);
    });

    // Mouseover temporarily pauses rotation but does not toggle pause/play button
    carouselElement.addEventListener("mouseenter", function () {
      hovered = true;
      updateRotation();
    });

    carouselElement.addEventListener("mouseleave", function () {
      hovered = false;
      updateRotation();
    });

    updateRotation();
  };

  // updates the aria-describedby on the next and prev btns
  const updateAriaDescribedBy = function (carouselElement) {
    const items = Array.from(carouselElement.querySelectorAll(".carousel-item"));
    const curIndex = items.findIndex((item) => item.classList.contains("active"));
    const prevIndex = (curIndex - 1 + items.length) % items.length;
    const nextIndex = (curIndex + 1) % items.length;

    const prevDataId = items[prevIndex]?.dataset.id;
    const nextDataId = items[nextIndex]?.dataset.id;
    if (prevDataId) {
      carouselElement
        .querySelector(".carousel-control-prev")
        ?.setAttribute("aria-describedby", "carousel-caption-" + prevDataId);
    }
    if (nextDataId) {
      carouselElement
        .querySelector(".carousel-control-next")
        ?.setAttribute("aria-describedby", "carousel-caption-" + nextDataId);
    }
  };

  class Carousel$3 {
    connect() {
      if (!Carousel$2) return

      document.querySelectorAll(".carousel").forEach((carouselElement) => {
        const carousel = Carousel$2.getOrCreateInstance(carouselElement);

        // on initial page load, set the aria-describedby on the btns for each carousel
        updateAriaDescribedBy(carouselElement);
        setupAutoplay(carouselElement, carousel);

        // on slide change
        carouselElement.addEventListener("slid.bs.carousel", function () {
          updateAriaDescribedBy(carouselElement);
        });
      });
    }
  }

  class ClearFormButton {
    connect() {
      const clearButtons = document.querySelectorAll(".btn-reset");

      clearButtons.forEach((clearBtn) => {
        const input =
          clearBtn.previousElementSibling &&
          clearBtn.previousElementSibling.id === "browse_q"
            ? clearBtn.previousElementSibling
            : null;

        if (!input) return

        const btnCheck = () => {
          if (input.value !== "") {
            clearBtn.style.display = "block";
          } else {
            clearBtn.style.display = "none";
          }
        };

        btnCheck();

        input.addEventListener("keyup", btnCheck);

        clearBtn.addEventListener("click", (event) => {
          event.preventDefault();
          input.value = "";
          btnCheck();
        });
      });
    }
  }

  // Bootstrap's ESM build exports Modal by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
  const Modal = bootstrap__namespace.Modal ?? bootstrap__namespace.default?.Modal;

  // Defined at module scope so that repeated calls to connect() (which runs on
  // every turbo:load) register the same listener, which the browser ignores.
  function handleClick(e) {
    const zprLink = e.target.closest(".zpr-link");
    if (!zprLink) return

    e.preventDefault();

    const modalElement = document.getElementById("blacklight-modal");
    if (!modalElement) return

    const modalDialog = modalElement.querySelector(".modal-dialog");
    const modalContent = modalDialog
      ? modalDialog.querySelector(".modal-content")
      : null;

    if (modalDialog) {
      modalDialog.classList.remove("modal-lg");
      modalDialog.classList.add("modal-xl");
    }

    if (modalContent) {
      modalContent.innerHTML = '<div id="osd-modal-container"></div>';
    }

    const closeText =
      (typeof Spotlight !== "undefined" &&
        Spotlight.ZprLinks &&
        Spotlight.ZprLinks.close) ||
      "Close";
    const zoomInText =
      (typeof Spotlight !== "undefined" &&
        Spotlight.ZprLinks &&
        Spotlight.ZprLinks.zoomIn) ||
      "Zoom in";
    const zoomOutText =
      (typeof Spotlight !== "undefined" &&
        Spotlight.ZprLinks &&
        Spotlight.ZprLinks.zoomOut) ||
      "Zoom out";

    const controls = `<div class="controls d-flex justify-content-center justify-content-md-end">
      <div class="custom-close-controls pe-3 pt-3">
        <button type="button" class="btn btn-dark" data-bs-dismiss="modal" aria-hidden="true">${closeText}</button>
      </div>
      <div class="zoom-controls mb-3 me-md-3">
        <button id="osd-zoom-in" type="button" class="btn btn-dark">${zoomInText}</button>
        <button id="osd-zoom-out" type="button" class="btn btn-dark">${zoomOutText}</button>
      </div>
      <div id="empty-div-required-by-osd"></div>
    </div>`;

    const osdModalContainer = document.getElementById("osd-modal-container");
    if (osdModalContainer) {
      const osdDiv = document.createElement("div");
      osdDiv.id = "osd-div";
      osdModalContainer.appendChild(osdDiv);
      osdModalContainer.insertAdjacentHTML("beforeend", controls);
    }

    const modalInstance = Modal.getOrCreateInstance(modalElement);
    modalInstance.show();

    const handleHiddenModal = () => {
      if (modalDialog) {
        modalDialog.classList.remove("modal-xl");
        modalDialog.classList.add("modal-lg");
      }
      modalElement.removeEventListener("hidden.bs.modal", handleHiddenModal);
    };
    modalElement.addEventListener("hidden.bs.modal", handleHiddenModal);

    let tileSource;
    const rawSource = zprLink.getAttribute("data-iiif-tilesource") || "";
    try {
      tileSource = JSON.parse(rawSource);
    } catch {
      tileSource = rawSource;
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
    });
  }

  class ZprLinks {
    connect() {
      document.addEventListener("click", handleClick);
    }
  }

  class UserIndex {
    connect() {
      new Carousel$3().connect();
      new ClearFormButton().connect();
      new ZprLinks().connect();
    }
  }

  class AddAnother {
    connect() {
      document
        .querySelectorAll("[data-action='add-another']")
        .forEach((button) => {
          button.addEventListener("click", (event) => {
            event.preventDefault();

            const templateId = button.dataset.templateId;
            if (!templateId) return

            const template = document.getElementById(templateId);
            if (!template) return

            const clone = document.importNode(template.content, true);

            const formGroup = button.closest(".form-group");
            if (!formGroup) return

            const firstNamedElement = clone.querySelector("[name]");
            if (!firstNamedElement) return

            const nameAttr = firstNamedElement.getAttribute("name");
            const existingElements = formGroup.querySelectorAll(
              `[name="${nameAttr}"]`,
            );
            const count = existingElements.length + 1;

            clone.querySelectorAll("[id]").forEach((el) => {
              const currentId = el.getAttribute("id");
              el.setAttribute("id", `${currentId}_${count}`);
            });

            clone.querySelectorAll("[for]").forEach((el) => {
              const currentFor = el.getAttribute("for");
              el.setAttribute("for", `${currentFor}_${count}`);
            });

            button.parentNode.insertBefore(clone, button);
          });
        });
    }
  }

  class AddNewButton {
    connect() {
      $("[data-expanded-add-button]").each((_i, el) =>
        this.addExpandBehaviorToButton($(el)),
      );
    }

    addExpandBehaviorToButton(button) {
      var settings = {
        speed: button.data("speed") || 450,
        animate_width: button.data("animate_width") || 425,
      };
      var target = $(button.data("field-target"));
      var save = $("input[data-behavior='save']", target);
      var cancel = $("input[data-behavior='cancel']", target);
      var input = $("input[type='text']", target);
      var original_width = button.outerWidth();
      var expanded = false;

      // Animate button open when the mouse enters or
      // the button is given focus (i.e. clicked/tabbed)
      button.on("mouseenter focus", function () {
        expandButton();
      });

      // Don't allow blank titles
      save.on("click", function () {
        if (inputEmpty()) {
          return false
        }
      });

      // Empty input and collapse
      // button on cancel click
      cancel.on("click", function (e) {
        e.preventDefault();
        input.val("");
        collapseButton();
      });

      // Collapse the button on when
      // an empty input loses focus
      input.on("blur", function () {
        if (inputEmpty()) {
          collapseButton();
        }
      });
      function expandButton() {
        // If this has not yet been expanded, recalculate original_width to
        // handle things that may have been originally hidden.
        if (!expanded) {
          original_width = button.outerWidth();
        }
        if (button.outerWidth() <= original_width + 5) {
          expanded = true;
          button.animate(
            { width: settings.animate_width + "px" },
            settings.speed,
            function () {
              target.show(0, function () {
                input.focus();
                // Set the button to auto width to make
                // sure it has room for any inputs
                button.width("auto");
                // Explicitly set the width of the button
                // so the close animation works properly
                button.width(button.width());
              });
            },
          );
        }
      }
      function collapseButton() {
        target.hide();
        button.animate({ width: original_width + "px" }, settings.speed);
      }
      function inputEmpty() {
        return $.trim(input.val()) == ""
      }
    }
  }

  class BlacklightConfiguration {
    connect() {
      // Add Select/Deselect all input behavior
      this.addCheckboxToggleBehavior();
      this.addEnableToggleBehavior();
    }

    // Add Select/Deselect all behavior for metadata field names for a given view e.g. Item details.
    addCheckboxToggleBehavior() {
      // Check number of checkboxes against the number of checked
      // checkboxes to determine if all of them are checked or not
      function allCheckboxesChecked(cells) {
        let total = 0;
        let checked = 0;
        cells.forEach((cell) => {
          cell.querySelectorAll("input[type='checkbox']").forEach((cb) => {
            total++;
            if (cb.checked) {
              checked++;
            }
          });
        });
        return total === checked
      }

      // Check or uncheck the "All" checkbox for each view column, e.g. Item details, List, etc.
      function updateSelectAllInput(checkbox, cells) {
        checkbox.checked = allCheckboxesChecked(cells);
      }

      document
        .querySelectorAll("[data-behavior='metadata-select']")
        .forEach((selectCheckbox) => {
          const parentCell = selectCheckbox.closest("th");
          if (!parentCell) return

          const table = parentCell.closest("table");
          if (!table) return

          const columnIndex = Array.from(parentCell.parentNode.children).indexOf(
            parentCell,
          );
          const columnRows = table.querySelectorAll(
            `tr td:nth-child(${columnIndex + 1})`,
          );

          const checkboxes = [];
          columnRows.forEach((cell) => {
            cell.querySelectorAll("input[type='checkbox']").forEach((cb) => {
              checkboxes.push(cb);
            });
          });

          updateSelectAllInput(selectCheckbox, columnRows);

          // Add the check/uncheck behavior to the select/deselect all checkbox
          selectCheckbox.addEventListener("click", () => {
            const allChecked = allCheckboxesChecked(columnRows);
            columnRows.forEach((cell) => {
              cell.querySelectorAll("input[type='checkbox']").forEach((cb) => {
                cb.checked = !allChecked;
                cb.dispatchEvent(new Event("change", { bubbles: true }));
              });
            });
            updateSelectAllInput(selectCheckbox, columnRows);
          });

          // When a single checkbox is selected/unselected, the "All" checkbox should be updated accordingly.
          checkboxes.forEach((cb) => {
            cb.addEventListener("change", () => {
              updateSelectAllInput(selectCheckbox, columnRows);
            });
          });
        });
    }

    addEnableToggleBehavior() {
      document
        .querySelectorAll("[data-behavior='enable-feature']")
        .forEach((checkbox) => {
          const targetSelector = checkbox.dataset.target;
          if (!targetSelector) return
          const target = document.querySelector(targetSelector);
          if (!target) return

          checkbox.addEventListener("change", () => {
            const isChecked = checkbox.checked;
            target.querySelectorAll("input[type='checkbox']").forEach((cb) => {
              if (!cb.matches("[data-behavior='enable-feature']")) {
                cb.checked = isChecked;
                cb.disabled = !isChecked;
                cb.dispatchEvent(new Event("change", { bubbles: true }));
              }
            });
          });
        });
    }
  }

  class Iiif {
    constructor(manifestUrl, manifest) {
      this.manifestUrl = manifestUrl;
      this.manifest = manifest;
    }

    sequences() {
      var it = {};
      var context = this;
      it[Symbol.iterator] = function* () {
        for (let sequence of context.manifest.sequences) {
          yield sequence;
        }
      };
      return it
    }

    canvases() {
      var it = {};
      var context = this;
      it[Symbol.iterator] = function* () {
        for (let sequence of context.sequences()) {
          for (let canvas of sequence.canvases) {
            yield canvas;
          }
        }
      };
      return it
    }

    images() {
      var it = {};
      var context = this;
      it[Symbol.iterator] = function* () {
        for (let canvas of context.canvases()) {
          for (let image of canvas.images) {
            var iiifService =
              image.resource?.service || image.resource?.default?.service;
            var iiifServiceId = iiifService["@id"];
            yield {
              thumb: iiifServiceId + "/full/!100,100/0/default.jpg",
              tilesource: iiifServiceId + "/info.json",
              manifest: context.manifestUrl,
              canvasId: canvas["@id"],
              imageId: image["@id"],
            };
          }
        }
      };
      return it
    }

    imagesArray() {
      return Array.from(this.images())
    }
  }

  // Module to add multi-image selector to widget panels

  function initMultiImageSelector(
    panel,
    image_versions,
    clickCallback,
    activeImageId,
  ) {
    const changeLink = document.createElement("a");
    changeLink.href = "javascript:;";
    changeLink.textContent = "Change";

    const thumbsListContainer = document.createElement("div");
    thumbsListContainer.className = "thumbs-list";
    thumbsListContainer.style.display = "none";

    const thumbList = document.createElement("ul");

    const imageIds = (image_versions || []).map((e) => e["imageId"]);

    init();

    function init() {
      destroyExistingImageSelector();
      if (image_versions && image_versions.length > 1) {
        addChangeLink();
        addThumbsList();
      }
    }

    function addChangeLink() {
      const pagination = panel.querySelector("[data-panel-image-pagination]");
      if (pagination) {
        pagination.innerHTML =
          "Image <span data-current-image='true'>" +
          indexOf(activeImageId) +
          "</span> of " +
          image_versions.length;
        pagination.style.display = "";
        pagination.appendChild(document.createTextNode(" "));
        pagination.appendChild(changeLink);
      }
      addChangeLinkBehavior();
    }

    function destroyExistingImageSelector() {
      const pagination = panel.querySelector("[data-panel-image-pagination]");
      if (pagination) {
        pagination.innerHTML = "";
        const nextEl = pagination.nextElementSibling;
        if (nextEl && nextEl.classList.contains("thumbs-list")) {
          nextEl.remove();
        }
      }
    }

    function indexOf(thumb) {
      const index = imageIds.indexOf(thumb);
      if (index > -1) {
        return index + 1
      } else {
        return 1
      }
    }

    function addChangeLinkBehavior() {
      changeLink.addEventListener("click", () => {
        if (thumbsListContainer.style.display === "none") {
          thumbsListContainer.style.display = "";
        } else {
          thumbsListContainer.style.display = "none";
        }
        updateThumbListWidth();
        addScrollBehavior();
        scrollToActiveThumb();
        loadVisibleThumbs();
        swapChangeLinkText(changeLink);
      });
    }

    function updateThumbListWidth() {
      let width = 0;
      thumbList.querySelectorAll("li").forEach((li) => {
        width += li.offsetWidth;
      });
      thumbList.style.width = width + 5 + "px";
    }

    function loadVisibleThumbs() {
      const viewportWidth = thumbsListContainer.clientWidth;
      let width = 0;
      thumbList.querySelectorAll("li").forEach((thisThumb) => {
        const image = thisThumb.querySelector("img");
        if (!image) return
        const thumbWidth = thisThumb.offsetWidth;
        width += thumbWidth;
        const totalWidth = width;
        const position = thumbList.offsetLeft + totalWidth - thumbWidth;

        if (position >= 0 && position < viewportWidth) {
          const dataSrc = image.dataset.src || image.getAttribute("data-src");
          if (dataSrc) {
            image.src = dataSrc;
          }
        }
      });
    }

    let scrollTimeout;
    function addScrollBehavior() {
      thumbsListContainer.addEventListener("scroll", () => {
        if (scrollTimeout) {
          clearTimeout(scrollTimeout);
        }
        scrollTimeout = setTimeout(() => {
          loadVisibleThumbs();
        }, 250);
      });
    }

    function scrollToActiveThumb() {
      const halfContainerWidth = thumbsListContainer.clientWidth / 2;
      const activeThumb =
        thumbList.querySelector(".active") || thumbList.querySelector("li");
      const activeThumbLeftPosition = activeThumb ? activeThumb.offsetLeft : 0;
      const halfActiveThumbWidth = activeThumb ? activeThumb.offsetWidth / 2 : 0;

      thumbsListContainer.scrollLeft =
        activeThumbLeftPosition - halfContainerWidth + halfActiveThumbWidth;
    }

    function addThumbsList() {
      addThumbsToList();
      updateActiveThumb();
      thumbsListContainer.appendChild(thumbList);
      const cardHeader = panel.querySelector(".card-header");
      if (cardHeader) {
        cardHeader.appendChild(thumbsListContainer);
      }
    }

    function updateActiveThumb() {
      thumbList.querySelectorAll("li").forEach((item) => {
        const img = item.querySelector("img");
        if (
          img &&
          (img.dataset.imageId == activeImageId ||
            img.getAttribute("data-image-id") == activeImageId)
        ) {
          item.classList.add("active");
        }
      });
    }

    function swapChangeLinkText(link) {
      link.textContent = link.textContent === "Change" ? "Close" : "Change";
    }

    function addThumbsToList() {
  (image_versions || []).forEach((version, i) => {
        const listItem = document.createElement("li");
        listItem.setAttribute("data-index", i.toString());

        const anchor = document.createElement("a");
        anchor.href = "javascript:;";

        const img = document.createElement("img");
        img.src = version["thumb"];
        img.setAttribute("data-image-id", version["imageId"]);

        if (version["src"]) {
          img.setAttribute("data-src", version["src"]);
        }

        anchor.appendChild(img);
        listItem.appendChild(anchor);

        listItem.addEventListener("click", () => {
          const src = img.getAttribute("src");

          if (typeof clickCallback === "function") {
            clickCallback(version);
          }

          const activeItem = thumbList.querySelector("li.active");
          if (activeItem) {
            activeItem.classList.remove("active");
          }
          listItem.classList.add("active");

          const panelImg = panel.querySelector(".pic img.img-thumbnail");
          if (panelImg) {
            panelImg.setAttribute("src", src);
          }

          const currentImgSpan = panel.querySelector(
            "[data-panel-image-pagination] [data-current-image]",
          );
          if (currentImgSpan) {
            currentImgSpan.textContent = (i + 1).toString();
          }
          scrollToActiveThumb();
        });

        img.addEventListener("load", () => {
          updateThumbListWidth();
        });

        thumbList.appendChild(listItem);
      });
    }
  }

  function multiImageSelector(
    panel,
    image_versions,
    clickCallback,
    activeImageId,
  ) {
    const element = panel && panel.jquery ? panel[0] : panel;
    if (!element) return

    initMultiImageSelector(element, image_versions, clickCallback, activeImageId);
  }

  function addImageSelector(input, panel, manifestUrl, initialize) {
    if (!manifestUrl) {
      showNonIiifAlert(input);
      return
    }
    var cropper = input.data("iiifCropper");
    fetch(manifestUrl)
      .then(function (response) {
        return response.json()
      })
      .then(function (manifest) {
        var iiifManifest = new Iiif(manifestUrl, manifest);

        var thumbs = iiifManifest.imagesArray();

        hideNonIiifAlert(input);

        if (initialize) {
          cropper.setIiifFields(thumbs[0]);
          multiImageSelector(panel); // Clears out existing selector
        }

        if (thumbs.length > 1) {
          panel.show();
          multiImageSelector(
            panel,
            thumbs,
            function (selectorImage) {
              cropper.setIiifFields(selectorImage);
            },
            cropper.iiifImageField.val(),
          );
        }
      });
  }

  function showNonIiifAlert(input) {
    input.parent().prev('[data-behavior="non-iiif-alert"]').show();
  }

  function hideNonIiifAlert(input) {
    input.parent().prev('[data-behavior="non-iiif-alert"]').hide();
  }

  const Spotlight$1 = (function () {
    var buffer = [];
    return {
      onLoad: function (func) {
        buffer.push(func);
      },

      activate: function () {
        this.sirTrevorIcon = window.sirTrevorIcon;
        for (var i = 0; i < buffer.length; i++) {
          buffer[i].call();
        }
      },
      csrfToken: function () {
        return document.querySelector("meta[name=csrf-token]")?.content
      },
      ZprLinks: {
        close:
          '<svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24"><path d="M0 0h24v24H0V0z" fill="none"/><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41z"/></svg>',
        zoomIn:
          '<svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24"><path d="M0 0h24v24H0V0z" fill="none"/><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14zm.5-7H9v2H7v1h2v2h1v-2h2V9h-2z"/></svg>\n',
        zoomOut:
          '<svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24"><path d="M0 0h24v24H0V0z" fill="none"/><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14zM7 9h5v1H7V9z"/></svg>\n',
      },
    }
  })();

  // This allows us to configure Spotlight in app/views/layouts/base.html.erb
  window.Spotlight = Spotlight$1;
  window.SirTrevor = SirTrevor$1;

  class Crop {
    constructor(cropArea, preserveAspectRatio = true) {
      // Extract raw DOM element if cropArea is a jQuery object
      this.cropArea = cropArea;
      if (this.cropArea) {
        this.cropArea.iiifCropper = this;
        if (typeof jQuery !== "undefined") {
          jQuery(this.cropArea).data("iiifCropper", this);
        }
      }

      // Get the cropper key and find the crop tool element
      const cropperKey = this.cropArea
        ? this.cropArea.dataset.cropperKey ||
          this.cropArea.getAttribute("data-cropper-key")
        : null;
      this.cropSelector = '[data-cropper="' + cropperKey + '"]';
      this.cropTool = document.querySelector(this.cropSelector);

      // Exhibit and masthead cropping requires the ratio between image width and height
      // to be consistent, whereas item widget cropping allows any combination of
      // image width and height.
      this.preserveAspectRatio = preserveAspectRatio;

      // Get the IIIF input elements used to store/reference IIIF information
      this.inputPrefix = this.cropTool
        ? this.cropTool.dataset.inputPrefix ||
          this.cropTool.getAttribute("data-input-prefix")
        : null;
      this.iiifUrlField = this.iiifInputElement(
        this.inputPrefix,
        "iiif_tilesource",
        this.cropTool,
      );
      this.iiifRegionField = this.iiifInputElement(
        this.inputPrefix,
        "iiif_region",
        this.cropTool,
      );
      this.iiifManifestField = this.iiifInputElement(
        this.inputPrefix,
        "iiif_manifest_url",
        this.cropTool,
      );
      this.iiifCanvasField = this.iiifInputElement(
        this.inputPrefix,
        "iiif_canvas_id",
        this.cropTool,
      );
      this.iiifImageField = this.iiifInputElement(
        this.inputPrefix,
        "iiif_image_id",
        this.cropTool,
      );

      // Get the closest form element
      this.form = this.cropArea ? this.cropArea.closest("form") : null;
      this.tileSource = null;
    }

    // Return the iiif input element based on the fieldname.
    // Multiple input fields with the same name on the page may be related
    // to a cropper. We thus need to pass in a parent element.
    iiifInputElement(inputPrefix, fieldName, inputParentElement) {
      if (inputParentElement && inputPrefix) {
        const selector = 'input[name="' + inputPrefix + "[" + fieldName + ']"]';
        const element = inputParentElement.querySelector(selector);
        if (element) {
          if (!element.val) {
            element.val = function (value) {
              if (value === undefined) {
                return this.value
              } else {
                this.value = value;
                return this
              }
            };
          }
          return element
        }
      }
      // Return a dummy object to prevent null-pointer exceptions
      return {
        value: undefined,
        val: function (value) {
          if (value === undefined) return undefined
          return this
        },
      }
    }

    // Render the cropper environment and add hooks into the autocomplete and upload forms
    render() {
      this.setupAutoCompletes();
      this.setupAjaxFileUpload();
      this.setupExistingIiifCropper();
    }

    // Setup the cropper on page load if the field
    // that holds the IIIF url is populated
    setupExistingIiifCropper() {
      if (this.iiifUrlField.val() === "") {
        return
      }

      this.addImageSelectorToExistingCropTool();
      this.setTileSource(this.iiifUrlField.val());
    }

    // Display the IIIF Cropper map with the current IIIF Layer (and cropbox, once the layer is available)
    setupIiifCropper() {
      this.loaded = false;

      this.renderCropperMap();

      if (this.imageLayer) {
        // Force a broken layer's container to be an element before removing.
        // Code in leaflet-iiif land calls delete on the image layer's container when removing,
        // which errors if there is an issue fetching the info.json and stops further necessary steps to execute.
        if (!this.imageLayer._container) {
          this.imageLayer._container = document.createElement("div");
        }
        this.cropperMap.removeLayer(this.imageLayer);
      }

      this.imageLayer = L.tileLayer.iiif(this.tileSource).addTo(this.cropperMap);

      var self = this;
      this.imageLayer.on("load", function () {
        if (!self.loaded) {
          var region = self.getCropRegion();
          self.positionIiifCropBox(region);
          self.loaded = true;
        }
      });

      this.cropAreaInitiallyVisible = this.isCropAreaVisible();
    }

    isCropAreaVisible() {
      if (!this.cropArea) return false
      return !!(
        this.cropArea.offsetWidth ||
        this.cropArea.offsetHeight ||
        this.cropArea.getClientRects().length
      )
    }

    // Get (or initialize) the current crop region from the form data
    getCropRegion() {
      var regionFieldValue = this.iiifRegionField.val();
      if (!regionFieldValue || regionFieldValue === "") {
        var region = this.defaultCropRegion();
        this.iiifRegionField.val(region);
        return region
      } else {
        return regionFieldValue.split(",")
      }
    }

    // Calculate a default crop region in the center of the image using the correct aspect ratio
    defaultCropRegion() {
      var imageWidth = this.imageLayer.x;
      var imageHeight = this.imageLayer.y;

      var boxWidth = Math.floor(imageWidth / 2);
      var boxHeight = Math.floor(boxWidth / this.aspectRatio());

      return [
        Math.floor((imageWidth - boxWidth) / 2),
        Math.floor((imageHeight - boxHeight) / 2),
        boxWidth,
        boxHeight,
      ]
    }

    // Calculate the required aspect ratio for the crop area
    aspectRatio() {
      if (!this.cropArea) return 1
      var cropWidth = parseInt(
        this.cropArea.dataset.cropWidth ||
          this.cropArea.getAttribute("data-crop-width"),
      );
      var cropHeight = parseInt(
        this.cropArea.dataset.cropHeight ||
          this.cropArea.getAttribute("data-crop-height"),
      );
      return cropWidth / cropHeight
    }

    // Position the IIIF Crop Box at the given IIIF region
    positionIiifCropBox(region) {
      var bounds = this.unprojectIIIFRegionToBounds(region);

      if (!this.cropBox) {
        this.renderCropBox(bounds);
      }

      this.cropBox.setBounds(bounds);
      this.cropperMap.invalidateSize();
      this.cropperMap.fitBounds(bounds);

      this.cropBox.editor.editLayer.clearLayers();
      this.cropBox.editor.refresh();
      this.cropBox.editor.initVertexMarkers();
    }

    // Set all of the various input fields to
    // the appropriate IIIF URL or identifier
    setIiifFields(iiifObject) {
      this.setTileSource(iiifObject.tilesource);
      this.iiifManifestField.val(iiifObject.manifest);
      this.iiifCanvasField.val(iiifObject.canvasId);
      this.iiifImageField.val(iiifObject.imageId);
    }

    // Set the Crop tileSource and setup the cropper
    setTileSource(source) {
      if (source == this.tileSource) {
        return
      }

      if (source === null || source === undefined) {
        console.error("No tilesource provided when setting up IIIF Cropper");
        return
      }

      if (this.cropBox) {
        this.iiifRegionField.val("");
      }

      this.tileSource = source;
      this.iiifUrlField.val(source);
      this.setupIiifCropper();
    }

    // Render the Leaflet Map into the crop area
    renderCropperMap() {
      if (this.cropperMap || !this.cropArea) {
        return
      }

      var cropperOptions = {
        editable: true,
        center: [0, 0],
        crs: L.CRS.Simple,
        zoom: 0,
      };

      if (this.preserveAspectRatio) {
        cropperOptions["editOptions"] = {
          rectangleEditorClass: this.aspectRatioPreservingRectangleEditor(
            this.aspectRatio(),
          ),
        };
      }

      this.cropperMap = L.map(
        this.cropArea.getAttribute("id") || this.cropArea.id,
        cropperOptions,
      );
      this.invalidateMapSizeOnTabToggle();
    }

    // Render the crop box (a Leaflet editable rectangle) onto the canvas
    renderCropBox(initialBounds) {
      this.cropBox = L.rectangle(initialBounds);
      this.cropBox.addTo(this.cropperMap);
      this.cropBox.enableEdit();
      this.cropBox
        .on("dblclick", L.DomEvent.stop)
        .on("dblclick", this.cropBox.toggleEdit);

      var self = this;
      this.cropperMap.on(
        "editable:dragend editable:vertex:dragend",
        function (e) {
          var bounds = e.layer.getBounds();
          var region = self.projectBoundsToIIIFRegion(bounds);

          self.iiifRegionField.val(region.join(","));
        },
      );
    }

    // Get the maximum zoom level for the IIIF Layer (always 1:1 image pixel to canvas?)
    maxZoom() {
      if (this.imageLayer) {
        return this.imageLayer.maxZoom
      }
    }

    // Take a Leaflet LatLngBounds object and transform it into a IIIF [x, y, w, h] region
    projectBoundsToIIIFRegion(bounds) {
      var min = this.cropperMap.project(bounds.getNorthWest(), this.maxZoom());
      var max = this.cropperMap.project(bounds.getSouthEast(), this.maxZoom());
      return [
        Math.max(Math.floor(min.x), 0),
        Math.max(Math.floor(min.y), 0),
        Math.floor(max.x - min.x),
        Math.floor(max.y - min.y),
      ]
    }

    // Take a IIIF [x, y, w, h] region and transform it into a Leaflet LatLngBounds
    unprojectIIIFRegionToBounds(region) {
      var minPoint = L.point(parseInt(region[0]), parseInt(region[1]));
      var maxPoint = L.point(
        parseInt(region[0]) + parseInt(region[2]),
        parseInt(region[1]) + parseInt(region[3]),
      );

      var min = this.cropperMap.unproject(minPoint, this.maxZoom());
      var max = this.cropperMap.unproject(maxPoint, this.maxZoom());
      return L.latLngBounds(min, max)
    }

    // TODO: Add accessors to update hidden inputs with IIIF uri/ids?

    // Setup autocomplete inputs to have the iiif_cropper context
    setupAutoCompletes() {
      if (!this.cropTool) return
      var input = this.cropTool.querySelector('[data-behavior="autocomplete"]');
      if (input) {
        input.iiifCropper = this;
        if (typeof jQuery !== "undefined") {
          jQuery(input).data("iiifCropper", this);
        }
      }
    }

    setupAjaxFileUpload() {
      if (!this.cropTool) return
      this.fileInput = this.cropTool.querySelector('input[type="file"]');
      if (this.fileInput) {
        this.fileInput.addEventListener("change", () => this.uploadFile());
      }
    }

    addImageSelectorToExistingCropTool() {
      if (this.iiifManifestField.val() === "") {
        return
      }

      if (!this.cropTool || typeof jQuery === "undefined") {
        return
      }

      var inputElement = this.cropTool.querySelector(
        '[data-behavior="autocomplete"]',
      );

      // Not every page which uses this module has autocomplete linked directly to the cropping tool
      if (inputElement) {
        var input = jQuery(inputElement);
        var targetPanel =
          inputElement.dataset.targetPanel ||
          inputElement.getAttribute("data-target-panel");
        var panelElement = document.querySelector(targetPanel);
        if (panelElement) {
          var panel = jQuery(panelElement);
          addImageSelector(
            input,
            panel,
            this.iiifManifestField.val(),
            !this.iiifImageField.val(),
          );
        }
      }
    }

    invalidateMapSizeOnTabToggle() {
      if (!this.form) return
      var tabs = this.form.querySelectorAll('[role="tablist"]');
      var self = this;
      var onTabShown = function () {
        if (self.cropAreaInitiallyVisible === false && self.isCropAreaVisible()) {
          self.cropperMap.invalidateSize();
          // Because the map size is 0,0 when image is loading (not visible) we need to refit the bounds of the layer
          self.imageLayer._fitBounds();
          self.cropAreaInitiallyVisible = null;
        }
      };

      tabs.forEach((tab) => {
        tab.addEventListener("shown.bs.tab", onTabShown);
      });

      if (typeof jQuery !== "undefined") {
        jQuery(tabs).on("shown.bs.tab", onTabShown);
      }
    }

    // Get all the form data with the exception of the _method field.
    getData() {
      if (!this.form) return null
      var data = new FormData(this.form);
      data.append("_method", null);
      return data
    }

    uploadFile() {
      if (!this.fileInput) return
      var url =
        this.fileInput.dataset.endpoint ||
        this.fileInput.getAttribute("data-endpoint");
      // Every post creates a new image/masthead.
      // Because they create IIIF urls which are heavily cached.
      fetch(url, {
        method: "POST",
        headers: {
          "X-CSRF-Token": Spotlight$1.csrfToken() || "",
          Accept: "application/json",
        },
        body: this.getData(),
      })
        .then((response) => {
          if (!response.ok) {
            return response.json().then(
              (json) => {
                var fakeXhr = { responseJSON: json };
                this.errorHandler(fakeXhr, "error", response.statusText);
              },
              () => {
                this.errorHandler({}, "error", "Upload failed");
              },
            )
          }
          return response.json()
        })
        .then((data) => {
          if (data) {
            this.successHandler(data, "success", null);
          }
        })
        .catch((error) => {
          this.errorHandler({}, "error", error.message);
        });
    }

    successHandler(data, _stat, _xhr) {
      this.setIiifFields({ tilesource: data.tilesource });
      this.setUploadId(data.id);
      this.clearUploadErrors();
    }

    errorHandler(xhr, _stat, _error) {
      let errorMessage = "Upload failed";
      if (xhr.responseJSON) {
        if (xhr.responseJSON.errors) {
          errorMessage = xhr.responseJSON.errors.join(", ");
        } else if (xhr.responseJSON.error) {
          errorMessage = xhr.responseJSON.error;
        }
      }
      this.showUploadError(errorMessage);
    }

    getUploadErrorsElement() {
      if (!this.cropTool) return null
      return this.cropTool.querySelector(".featured-image.invalid-feedback")
    }

    showUploadError(errorMessage) {
      const errorsElement = this.getUploadErrorsElement();
      if (errorsElement) {
        errorsElement.textContent = errorMessage;
        errorsElement.style.display = "block";
      } else {
        console.error("uploadFile", errorMessage);
      }
    }

    clearUploadErrors() {
      const errorsElement = this.getUploadErrorsElement();
      if (errorsElement) {
        errorsElement.textContent = "";
        errorsElement.style.display = "none";
      }
    }

    setUploadId(id) {
      // This input is currently used for exhibit masthead or thumbnail image upload.
      // The name should be sufficient in this case, as we don't use this part of the
      // code for solr document widgets where we enable cropping.
      // If we require more specificity, we can scope this to this.cropTool.
      const selector = 'input[name="' + this.inputPrefix + '[upload_id]"]';
      const element = document.querySelector(selector);
      if (element) {
        element.value = id;
      }
    }

    aspectRatioPreservingRectangleEditor(aspect) {
      return L.Editable.RectangleEditor.extend({
        extendBounds: function (e) {
          var index = e.vertex.getIndex(),
            next = e.vertex.getNext(),
            previous = e.vertex.getPrevious(),
            oppositeIndex = (index + 2) % 4,
            opposite = e.vertex.latlngs[oppositeIndex];

          if (index % 2 == 1) {
            // calculate horiz. displacement
            e.latlng.update([
              opposite.lat + (1 / aspect) * (opposite.lng - e.latlng.lng),
              e.latlng.lng,
            ]);
          } else {
            // calculate vert. displacement
            e.latlng.update([
              e.latlng.lat,
              opposite.lng - aspect * (opposite.lat - e.latlng.lat),
            ]);
          }
          var bounds = new L.LatLngBounds(e.latlng, opposite);
          // Update latlngs by hand to preserve order.
          previous.latlng.update([e.latlng.lat, opposite.lng]);
          next.latlng.update([opposite.lat, e.latlng.lng]);
          this.updateBounds(bounds);
          this.refreshVertexMarkers();
        },
      })
    }
  }

  class CroppableModal {
    attachModalHandlers() {
      // Attach handler for when modal first loads, to show the cropper
      this.attachModalLoadBehavior();
      // Attach handler for save by checking if clicking in the modal is on a save button
      this.attachModalSaveHandler();
    }

    attachModalLoadBehavior() {
      // Listen for event thrown when modal is displayed with content
      document.addEventListener(
        "loaded.blacklight.blacklight-modal",
        function (e) {
          const dataCropperDiv = document.querySelector(
            '#blacklight-modal [data-behavior="iiif-cropper"]',
          );

          if (dataCropperDiv) {
            new Crop($(dataCropperDiv), false).render();
          }
        },
      );
    }

    // Field names are of the format item[item_0][iiif_image_id]
    iiifInputField(itemIndex, fieldName, parentElement) {
      const itemPrefix = "item[" + itemIndex + "]";
      const selector = 'input[name="' + itemPrefix + "[" + fieldName + ']"]';
      return parentElement ? parentElement.querySelector(selector) : null
    }

    attachModalSaveHandler() {
      const context = this;

      document.addEventListener("show.blacklight.blacklight-modal", function (e) {
        const saveBtn = document.getElementById("save-cropping-selection");
        if (saveBtn) {
          saveBtn.addEventListener("click", () => {
            context.saveCroppedRegion();
          });
        }
      });
    }

    saveCroppedRegion() {
      //On hitting "save changes", we need to copy over the value
      //to the iiif thumbnail url input field as well as the image source itself
      const context = this;
      const dataCropperDiv = document.querySelector(
        '#blacklight-modal [data-behavior="iiif-cropper"]',
      );

      if (dataCropperDiv) {
        const dataCropperKey =
          dataCropperDiv.dataset.cropperKey ||
          dataCropperDiv.getAttribute("data-cropper-key");
        const itemIndex =
          dataCropperDiv.dataset.indexId ||
          dataCropperDiv.getAttribute("data-index-id");

        // Get the element on the main edit page whose select image link opened up the modal
        const itemElement = document.querySelector(
          '[data-cropper="' + dataCropperKey + '"]',
        );
        if (!itemElement) return

        // Get the hidden input field on the main edit page corresponding to this item
        const thumbnailSaveField = context.iiifInputField(
          itemIndex,
          "thumbnail_image_url",
          itemElement,
        );
        const fullimageSaveField = context.iiifInputField(
          itemIndex,
          "full_image_url",
          itemElement,
        );

        const iiifTilesourceField = context.iiifInputField(
          itemIndex,
          "iiif_tilesource",
          itemElement,
        );
        const regionValueField = context.iiifInputField(
          itemIndex,
          "iiif_region",
          itemElement,
        );

        const iiifTilesource = iiifTilesourceField
          ? iiifTilesourceField.value
          : "";
        const regionValue = regionValueField ? regionValueField.value : "";

        // Extract the region string to incorporate into the thumbnail URL
        const lastIndex = iiifTilesource.lastIndexOf("/info.json");
        const urlPrefix =
          lastIndex !== -1
            ? iiifTilesource.substring(0, lastIndex)
            : iiifTilesource;
        const thumbnailUrl =
          urlPrefix + "/" + regionValue + "/!400,400/0/default.jpg";

        // Set the hidden input value to the thumbnail URL
        // Also set the full image - which is used by widgets like carousel or slideshow
        if (thumbnailSaveField) {
          thumbnailSaveField.value = thumbnailUrl;
          thumbnailSaveField.dispatchEvent(new Event("change", { bubbles: true }));
        }
        if (fullimageSaveField) {
          fullimageSaveField.value =
            urlPrefix + "/" + regionValue + "/!800,800/0/default.jpg";
          fullimageSaveField.dispatchEvent(new Event("change", { bubbles: true }));
        }

        // Also change img url for thumbnail image
        const itemImage = itemElement.querySelector("img.img-thumbnail");
        if (itemImage) {
          itemImage.setAttribute("src", thumbnailUrl);
        }
      }
    }
  }

  class Croppable {
    connect() {
      // For exhibit masthead or thumbnail pages, where
      // the div exists on page load
      document
        .querySelectorAll('[data-behavior="iiif-cropper"]')
        .forEach((cropElement) => {
          new Crop(cropElement).render();
        });

      // In the case of individual document thumbnails, selection
      // of the image is through a modal. Here we attach the event
      new CroppableModal().attachModalHandlers();
    }
  }

  /*
    Simple plugin add edit-in-place behavior
  */
  class EditInPlace {
    connect() {
      $("[data-in-place-edit-target]").each(function () {
        $(this).on("click.inplaceedit", function () {
          var $label = $(this).find($(this).data("in-place-edit-target"));
          var $input = $(this).find($(this).data("in-place-edit-field-target"));

          // hide the edit-in-place affordance icon while in edit mode
          $(this).addClass("hide-edit-icon");
          $label.hide();
          $input.val($label.text());
          $input.attr("type", "text");
          $input.select();
          $input.focus();

          $input.on("keypress", function (e) {
            if (e.which == 13) {
              $input.trigger("blur.inplaceedit");
              return false
            }
          });

          $input.on("blur.inplaceedit", function () {
            var value = $input.val();

            if ($.trim(value).length == 0) {
              $input.val($label.text());
            } else {
              $label.text(value);
            }

            $label.show();
            $input.attr("type", "hidden");
            // when leaving edit mode, should no longer hide edit-in-place affordance icon
            $("[data-in-place-edit-target]").removeClass("hide-edit-icon");

            return false
          });

          return false
        });
      });

      $("[data-behavior='restore-default']").each(function () {
        var hidden = $("[data-default-value]", $(this));
        var value = $(
          $("[data-in-place-edit-target]", $(this)).data("in-place-edit-target"),
          $(this),
        );
        var button = $("[data-restore-default]", $(this));

        hidden.on("keypress", function (e) {
          if (e.which == 13) {
            hidden.trigger("blur");
            return false
          }
        });

        hidden.on("blur", function () {
          if ($(this).val() == $(this).data("default-value")) {
            button.addClass("d-none");
          } else {
            button.removeClass("d-none");
          }
        });
        button.on("click", function (e) {
          e.preventDefault();
          hidden.val(hidden.data("default-value"));
          value.text(hidden.data("default-value"));
          button.hide();
        });
      });
    }
  }

  /*
  https://gist.github.com/pjambet/3710461
  */
  var LATIN_MAP = {
    'À': 'A', 'Á': 'A', 'Â': 'A', 'Ã': 'A', 'Ä': 'A', 'Å': 'A', 'Æ': 'AE', 'Ç':
    'C', 'È': 'E', 'É': 'E', 'Ê': 'E', 'Ë': 'E', 'Ì': 'I', 'Í': 'I', 'Î': 'I',
    'Ï': 'I', 'Ð': 'D', 'Ñ': 'N', 'Ò': 'O', 'Ó': 'O', 'Ô': 'O', 'Õ': 'O', 'Ö':
    'O', 'Ő': 'O', 'Ø': 'O', 'Ù': 'U', 'Ú': 'U', 'Û': 'U', 'Ü': 'U', 'Ű': 'U',
    'Ý': 'Y', 'Þ': 'TH', 'ß': 'ss', 'à':'a', 'á':'a', 'â': 'a', 'ã': 'a', 'ä':
    'a', 'å': 'a', 'æ': 'ae', 'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ð': 'd', 'ñ': 'n', 'ò': 'o', 'ó':
    'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ő': 'o', 'ø': 'o', 'ù': 'u', 'ú': 'u',
    'û': 'u', 'ü': 'u', 'ű': 'u', 'ý': 'y', 'þ': 'th', 'ÿ': 'y'
  };
  var LATIN_SYMBOLS_MAP = {
    '©':'(c)'
  };
  var GREEK_MAP = {
    'α':'a', 'β':'b', 'γ':'g', 'δ':'d', 'ε':'e', 'ζ':'z', 'η':'h', 'θ':'8',
    'ι':'i', 'κ':'k', 'λ':'l', 'μ':'m', 'ν':'n', 'ξ':'3', 'ο':'o', 'π':'p',
    'ρ':'r', 'σ':'s', 'τ':'t', 'υ':'y', 'φ':'f', 'χ':'x', 'ψ':'ps', 'ω':'w',
    'ά':'a', 'έ':'e', 'ί':'i', 'ό':'o', 'ύ':'y', 'ή':'h', 'ώ':'w', 'ς':'s',
    'ϊ':'i', 'ΰ':'y', 'ϋ':'y', 'ΐ':'i',
    'Α':'A', 'Β':'B', 'Γ':'G', 'Δ':'D', 'Ε':'E', 'Ζ':'Z', 'Η':'H', 'Θ':'8',
    'Ι':'I', 'Κ':'K', 'Λ':'L', 'Μ':'M', 'Ν':'N', 'Ξ':'3', 'Ο':'O', 'Π':'P',
    'Ρ':'R', 'Σ':'S', 'Τ':'T', 'Υ':'Y', 'Φ':'F', 'Χ':'X', 'Ψ':'PS', 'Ω':'W',
    'Ά':'A', 'Έ':'E', 'Ί':'I', 'Ό':'O', 'Ύ':'Y', 'Ή':'H', 'Ώ':'W', 'Ϊ':'I',
    'Ϋ':'Y'
  };
  var TURKISH_MAP = {
    'ş':'s', 'Ş':'S', 'ı':'i', 'İ':'I', 'ç':'c', 'Ç':'C', 'ü':'u', 'Ü':'U',
    'ö':'o', 'Ö':'O', 'ğ':'g', 'Ğ':'G'
  };
  var RUSSIAN_MAP = {
    'а':'a', 'б':'b', 'в':'v', 'г':'g', 'д':'d', 'е':'e', 'ё':'yo', 'ж':'zh',
    'з':'z', 'и':'i', 'й':'j', 'к':'k', 'л':'l', 'м':'m', 'н':'n', 'о':'o',
    'п':'p', 'р':'r', 'с':'s', 'т':'t', 'у':'u', 'ф':'f', 'х':'h', 'ц':'c',
    'ч':'ch', 'ш':'sh', 'щ':'sh', 'ъ':'', 'ы':'y', 'ь':'', 'э':'e', 'ю':'yu',
    'я':'ya',
    'А':'A', 'Б':'B', 'В':'V', 'Г':'G', 'Д':'D', 'Е':'E', 'Ё':'Yo', 'Ж':'Zh',
    'З':'Z', 'И':'I', 'Й':'J', 'К':'K', 'Л':'L', 'М':'M', 'Н':'N', 'О':'O',
    'П':'P', 'Р':'R', 'С':'S', 'Т':'T', 'У':'U', 'Ф':'F', 'Х':'H', 'Ц':'C',
    'Ч':'Ch', 'Ш':'Sh', 'Щ':'Sh', 'Ъ':'', 'Ы':'Y', 'Ь':'', 'Э':'E', 'Ю':'Yu',
    'Я':'Ya'
  };
  var UKRAINIAN_MAP = {
    'Є':'Ye', 'І':'I', 'Ї':'Yi', 'Ґ':'G', 'є':'ye', 'і':'i', 'ї':'yi', 'ґ':'g'
  };
  var CZECH_MAP = {
    'č':'c', 'ď':'d', 'ě':'e', 'ň': 'n', 'ř':'r', 'š':'s', 'ť':'t', 'ů':'u',
    'ž':'z', 'Č':'C', 'Ď':'D', 'Ě':'E', 'Ň': 'N', 'Ř':'R', 'Š':'S', 'Ť':'T',
    'Ů':'U', 'Ž':'Z'
  };

  var POLISH_MAP = {
    'ą':'a', 'ć':'c', 'ę':'e', 'ł':'l', 'ń':'n', 'ó':'o', 'ś':'s', 'ź':'z',
    'ż':'z', 'Ą':'A', 'Ć':'C', 'Ę':'e', 'Ł':'L', 'Ń':'N', 'Ó':'o', 'Ś':'S',
    'Ź':'Z', 'Ż':'Z'
  };

  var LATVIAN_MAP = {
    'ā':'a', 'č':'c', 'ē':'e', 'ģ':'g', 'ī':'i', 'ķ':'k', 'ļ':'l', 'ņ':'n',
    'š':'s', 'ū':'u', 'ž':'z', 'Ā':'A', 'Č':'C', 'Ē':'E', 'Ģ':'G', 'Ī':'i',
    'Ķ':'k', 'Ļ':'L', 'Ņ':'N', 'Š':'S', 'Ū':'u', 'Ž':'Z'
  };

  var ALL_DOWNCODE_MAPS=new Array();
  ALL_DOWNCODE_MAPS[0]=LATIN_MAP;
  ALL_DOWNCODE_MAPS[1]=LATIN_SYMBOLS_MAP;
  ALL_DOWNCODE_MAPS[2]=GREEK_MAP;
  ALL_DOWNCODE_MAPS[3]=TURKISH_MAP;
  ALL_DOWNCODE_MAPS[4]=RUSSIAN_MAP;
  ALL_DOWNCODE_MAPS[5]=UKRAINIAN_MAP;
  ALL_DOWNCODE_MAPS[6]=CZECH_MAP;
  ALL_DOWNCODE_MAPS[7]=POLISH_MAP;
  ALL_DOWNCODE_MAPS[8]=LATVIAN_MAP;

  var Downcoder = new Object();
  Downcoder.Initialize = function()
  {
    if (Downcoder.map) // already made
      return ;
      Downcoder.map ={};
      Downcoder.chars = '' ;
      for(var i in ALL_DOWNCODE_MAPS)
      {
        var lookup = ALL_DOWNCODE_MAPS[i];
        for (var c in lookup)
        {
          Downcoder.map[c] = lookup[c] ;
          Downcoder.chars += c ;
        }
      }
      Downcoder.regex = new RegExp('[' + Downcoder.chars + ']|[^' + Downcoder.chars + ']+','g') ;
    };
    
  const downcode = function( slug )
  {
    Downcoder.Initialize() ;
    var downcoded ="";
    var pieces = slug.match(Downcoder.regex);
    if(pieces)
    {
      for (var i = 0 ; i < pieces.length ; i++)
      {
        if (pieces[i].length == 1)
        {
          var mapped = Downcoder.map[pieces[i]] ;
          if (mapped != null)
          {
            downcoded+=mapped;
            continue ;
          }
        }
        downcoded+=pieces[i];
      }
    }
    else
    {
      downcoded = slug;
    }
    return downcoded;
  };


  function URLify(s, num_chars) {
    // changes, e.g., "Petty theft" to "petty_theft"
    // remove all these words from the string before urlifying
    s = downcode(s);
    //
    // if downcode doesn't hit, the char will be stripped here
    s = s.replace(/[^-\w\s]/g, ' ');  // remove unneeded chars
    s = s.replace(/^\s+|\s+$/g, ''); // trim leading/trailing spaces
    s = s.replace(/[-\s]+/g, '-');   // convert spaces to hyphens
    s = s.toLowerCase();             // convert to lowercase
    return s.substring(0, num_chars);// trim to first num_chars chars
  }

  class Exhibits {
    connect() {
      // auto-fill the exhibit slug on the new exhibit form
      const newExhibit = document.getElementById("new_exhibit");
      if (newExhibit) {
        const exhibitTitle = document.getElementById("exhibit_title");
        const exhibitSlug = document.getElementById("exhibit_slug");

        if (exhibitTitle && exhibitSlug) {
          const updatePlaceholder = () => {
            const val = exhibitTitle.value || "";
            exhibitSlug.placeholder = URLify(val, val.length);
          };

          exhibitTitle.addEventListener("change", updatePlaceholder);
          exhibitTitle.addEventListener("keyup", updatePlaceholder);

          exhibitSlug.addEventListener("focus", () => {
            if (exhibitSlug.value === "") {
              exhibitSlug.value = exhibitSlug.placeholder || "";
            }
          });
        }
      }

      const anotherEmail = document.getElementById("another-email");
      if (anotherEmail) {
        anotherEmail.addEventListener("click", (e) => {
          e.preventDefault();

          const container = anotherEmail.closest(".form-group");
          if (!container) return

          const contacts = container.querySelectorAll(".contact");
          if (contacts.length === 0) return

          const firstContact = contacts[0];
          const inputContainer = firstContact.cloneNode(true);

          // wipe out any values from the inputs
          const inputs = inputContainer.querySelectorAll("input");
          inputs.forEach((input) => {
            input.value = "";
            const originalId = input.getAttribute("id");
            if (originalId) {
              input.setAttribute(
                "id",
                originalId.replace("0", contacts.length.toString()),
              );
            }
            const originalName = input.getAttribute("name");
            if (originalName) {
              input.setAttribute(
                "name",
                originalName.replace("0", contacts.length.toString()),
              );
            }
            const originalAriaLabel = input.getAttribute("aria-label");
            if (originalAriaLabel) {
              input.setAttribute(
                "aria-label",
                originalAriaLabel.replace("1", (contacts.length + 1).toString()),
              );
            }
          });

          inputContainer
            .querySelectorAll(".contact-email-delete-wrapper")
            .forEach((el) => el.remove());
          inputContainer
            .querySelectorAll(".confirmation-status")
            .forEach((el) => el.remove());

          // bootstrap does not render input-groups with only one value in them correctly.
          const onlyChildInputs = inputContainer.querySelectorAll(
            ".input-group input:only-child",
          );
          onlyChildInputs.forEach((input) => {
            const group = input.closest(".input-group");
            if (group) {
              group.classList.remove("input-group");
            }
          });

          contacts[contacts.length - 1].after(inputContainer);
        });
      }

      if (document.getElementById("another-email")) {
        document.addEventListener(
          "turbo:submit-end",
          this.contactToDeleteNotFoundHandler,
        );
      }

      // Put focus in saved search title input when Save this search modal is shown
      const saveModal = document.getElementById("save-modal");
      if (saveModal) {
        saveModal.addEventListener("shown.bs.modal", () => {
          const searchTitle = document.getElementById("search_title");
          if (searchTitle) {
            searchTitle.focus();
          }
        });
      }
    }

    contactToDeleteNotFoundHandler(e) {
      const contact =
        e.detail.formSubmission?.delegate?.element?.querySelector(".contact");
      if (contact && e.detail?.fetchResponse?.response?.status === 404) {
        const error = contact.querySelector(".contact-email-delete-error");
        if (error) {
          error.style.display = "block";
          const errorMsg = error.querySelector(".error-msg");
          if (errorMsg) {
            errorMsg.textContent = "Not Found";
          }
        }
      }
    }
  }

  (function ($, _) {

    /*
     * SerializedForm is built as a singleton jQuery plugin. It needs to be able to
     * handle instantiation from multiple sources, and use the [data-form-observer]
     * as global state object.
     */
    $.SerializedForm = function () {
      var $serializedForm;
      var plugin = this;

      // Store form serialization in data attribute
      function serializeFormStatus() {
        $serializedForm.data(
          "serialized-form",
          formSerialization($serializedForm),
        );
      }

      // Do custom serialization of the sir-trevor form data. This needs to be a
      // passed in argument for comparison later on.
      function formSerialization(form) {
        var content_editable = [];
        var i = 0;
        $("[contenteditable='true']", form).each(function () {
          content_editable.push("&contenteditable_" + i + "=" + $(this).text());
        });
        return form.serialize() + content_editable.join()
      }

      // Unbind observing form on submit (which we have to do because of turbolinks)
      function unbindObservedFormSubmit() {
        $serializedForm.on("submit", function () {
          $(this).data("being-submitted", true);
        });
      }

      // Get the stored serialized form status
      function serializedFormStatus() {
        return $serializedForm.data("serialized-form")
      }

      // Check all observed forms on page for status change
      plugin.observedFormsStatusHasChanged = function () {
        var unsaved_changes = false;
        $("[data-form-observer]").each(function () {
          if (!$(this).data("being-submitted")) {
            if (serializedFormStatus() != formSerialization($(this))) {
              unsaved_changes = true;
            }
          }
        });
        return unsaved_changes
      };

      function init() {
        $serializedForm = $("[data-form-observer]");
        serializeFormStatus();
        unbindObservedFormSubmit();
      }

      init();

      return plugin
    };
  })(jQuery);

  class FormObserver {
    connect() {
      // Instantiate the singleton SerializedForm plugin
      var serializedForm = $.SerializedForm();
      $(window).on(
        "beforeunload page:before-change turbolinks:before-visit turbo:before-visit",
        function (event) {
          // Don't handle the same event twice #turbolinks
          if (event.handled !== true) {
            if (serializedForm.observedFormsStatusHasChanged()) {
              event.handled = true;
              var message =
                "You have unsaved changes. Are you sure you want to leave this page?";
              // There are variations in how Webkit browsers may handle this:
              // https://developer.mozilla.org/en-US/docs/Web/Events/beforeunload
              if (event.type == "beforeunload") {
                return message
              } else {
                return confirm(message)
              }
            }
          }
        },
      );
    }
  }

  class Locks {
    delete_lock(el) {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

      fetch(el.dataset.lock, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": csrfToken,
        },
      });

      el.removeAttribute("data-lock");
    }

    connect() {
      document.querySelectorAll("[data-lock]").forEach((element) => {
        element.addEventListener("click", (e) => {
          this.delete_lock(e.target);
        });
      });
    }
  }

  // Place all the behaviors and hooks related to the matching controller here.
  // All this logic will automatically be available in application.js.

  class Pages {
    connect() {
      SirTrevor.setDefaults({
        iconUrl: Spotlight.sirTrevorIcon,
        uploadUrl: $("[data-attachment-endpoint]").data("attachment-endpoint"),
        ajaxOptions: {
          headers: {
            "X-CSRF-Token": Spotlight$1.csrfToken() || "",
          },
          credentials: "same-origin",
        },
      });

      SirTrevor.Blocks.Heading.prototype.toolbarEnabled = true;
      SirTrevor.Blocks.Quote.prototype.toolbarEnabled = true;
      SirTrevor.Blocks.Text.prototype.toolbarEnabled = true;

      var instance = $(".js-st-instance").first();

      if (instance.length) {
        var editor = new SirTrevor.Editor({
          el: instance[0],
          blockTypes: instance.data("blockTypes"),
          altTextSettings: instance.data("altTextSettings"),
          defaultType: ["Text"],
          onEditorRender: function () {
            $.SerializedForm();
          },
          blockTypeLimits: {
            SearchResults: 1,
          },
        });

        editor.blockControls = Spotlight$1.BlockControls.create(editor);

        new Spotlight$1.BlockLimits(editor).enforceLimits(editor);
      }
    }
  }

  class ProgressMonitor {
    connect() {
      var monitorElements = $('[data-behavior="progress-panel"]');
      var defaultRefreshRate = 3000;
      var panelContainer;
      var pollers = [];

      $(monitorElements).each(function () {
        panelContainer = $(this);
        panelContainer.hide();
        var monitorUrl = panelContainer.data("monitorUrl");
        var refreshRate = panelContainer.data("refreshRate") || defaultRefreshRate;
        pollers.push(
          setInterval(function () {
            checkMonitorUrl(monitorUrl);
          }, refreshRate),
        );
      });

      // Clear the intervals on turbolink:click event (e.g. when the user navigates away from the page)
      $(document).on("turbolinks:click", function () {
        if (pollers.length > 0) {
          $.each(pollers, function () {
            clearInterval(this);
          });
          pollers = [];
        }
      });

      function checkMonitorUrl(url) {
        fetch(url)
          .then(function (response) {
            if (!response.ok) {
              throw new Error("Network response was not ok")
            }
            return response.json()
          })
          .then(success)
          .catch(fail);
      }

      function success(data) {
        if (data.recently_in_progress) {
          updateMonitorPanel(data);
          monitorPanel().show();
        } else {
          monitorPanel().hide();
        }
      }

      function fail() {
        monitorPanel().hide();
      }

      function updateMonitorPanel(data) {
        panelStartDate().text(data.started_at);
        panelCurrentDate().text(data.updated_at);
        panelCompletedDate().text(data.updated_at);
        panelCurrent().text(data.completed);
        setPanelCompleted(data.finished);
        updatePanelTotals(data);
        updatePanelErrorMessage(data);
        updateProgressBar(data);

        panelContainer.show();
      }

      function updateProgressBar(data) {
        var percentage = calculatePercentage(data);
        progressBar()
          .attr("aria-valuemax", data.total)
          .attr("aria-valuenow", percentage)
          .css("width", percentage + "%")
          .text(percentage + "%");

        if (data.finished) {
          progressBar().removeClass("active").removeClass("progress-bar-striped");
        }
      }

      function updatePanelErrorMessage(data) {
        // We currently do not store this state,
        // but with this code we can in the future.
        if (data.errored) {
          panelErrorMessage().show();
        } else {
          panelErrorMessage().hide();
        }
      }

      function updatePanelTotals(data) {
        panelTotals().each(function () {
          $(this).text(data.total);
        });
      }

      function calculatePercentage(data) {
        if (data.total == 0) return 0
        return Math.floor((data.completed / data.total) * 100)
      }

      function monitorPanel() {
        return panelContainer.find(".index-status")
      }

      function panelStartDate() {
        return monitorPanel()
          .find('[data-behavior="monitor-start"]')
          .find('[data-behavior="date"]')
      }

      function panelCurrentDate() {
        return monitorPanel()
          .find('[data-behavior="monitor-current"]')
          .find('[data-behavior="date"]')
      }

      function panelCompletedDate() {
        return monitorPanel()
          .find('[data-behavior="monitor-completed"]')
          .find('[data-behavior="date"]')
      }

      function panelTotals() {
        return monitorPanel().find('[data-behavior="total"]')
      }

      function panelCurrent() {
        return monitorPanel()
          .find('[data-behavior="monitor-current"]')
          .find('[data-behavior="completed"]')
      }

      function progressBar() {
        return monitorPanel().find(".progress-bar")
      }

      function panelErrorMessage() {
        return monitorPanel().find('[data-behavior="monitor-error"]')
      }

      function setPanelCompleted(finished) {
        var panel = monitorPanel().find('[data-behavior="monitor-completed"]');

        if (finished) {
          panel.show();
        } else {
          panel.hide();
        }
      }

      return this
    }
  }

  class ReadonlyCheckbox {
    connect() {
      // Don't allow unchecking of checkboxes with the data-readonly attribute
      $("input[type='checkbox'][data-readonly]").on("click", function (event) {
        event.preventDefault();
      });
    }
  }

  const docStore = new Map();

  function highlight(value, query) {
    if (query.trim() === "") return value
    const queryValue = query.trim();
    return queryValue
      ? value.replace(new RegExp(queryValue, "gi"), "<strong>$&</strong>")
      : value
  }

  function templateFunc(obj, query) {
    const thumbnail = obj.thumbnail
      ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>`
      : "";
    const privateClass = obj.private ? " blacklight-private" : "";
    const title = highlight(obj.title, query);
    const description = obj.description
      ? `<small>&nbsp;&nbsp;${highlight(obj.description, query)}</small>`
      : "";
    return `<div class="autocomplete-item${privateClass}">${thumbnail}
            <span class="autocomplete-title">${title}</span><br/>${description}
          </div>`
  }

  function autoCompleteElementTemplate(obj, query) {
    return `<li role="option" data-autocomplete-value="${obj.id}">${templateFunc(obj, query)}</li>`
  }

  function getAutoCompleteElementDataMap(autoCompleteElement) {
    if (!docStore.has(autoCompleteElement.id)) {
      docStore.set(autoCompleteElement.id, new Map());
    }
    return docStore.get(autoCompleteElement.id)
  }

  async function fetchResult(url) {
    const result = await fetchAutocompleteJSON(url);
    const docs = result.docs || [];
    const query = this.querySelector("input").value || "";
    const autoCompleteElementDataMap = getAutoCompleteElementDataMap(this);
    return docs
      .map((doc) => {
        autoCompleteElementDataMap.set(doc.id, doc);
        return autoCompleteElementTemplate(doc, query)
      })
      .join("")
  }

  function addAutocompletetoFeaturedImage() {
    const autocompletePath = $(
      "form[data-autocomplete-exhibit-catalog-path]",
    ).data("autocomplete-exhibit-catalog-path");
    const featuredImageTypeaheads = $("[data-featured-image-typeahead]");
    if (featuredImageTypeaheads.length === 0) return

    $.each(featuredImageTypeaheads, function (index, autoCompleteInput) {
      const autoCompleteElement = autoCompleteInput.closest("auto-complete");

      autoCompleteElement.setAttribute("src", autocompletePath);
      autoCompleteElement.fetchResult = fetchResult;
      autoCompleteElement.addEventListener("auto-complete-change", (e) => {
        const data = getAutoCompleteElementDataMap(autoCompleteElement).get(
          e.relatedTarget.value,
        );
        if (!data) return

        const inputElement = $(e.relatedTarget);
        const panel = document.querySelector(e.relatedTarget.dataset.targetPanel);
        e.relatedTarget.value = data.title;
        addImageSelector(inputElement, $(panel), data.iiif_manifest, true);
        $(inputElement.data("id-field")).val(data["global_id"]);
        inputElement.attr("type", "text");
      });
    });
  }

  async function fetchAutocompleteJSON(url) {
    const res = await fetch(url.toString());
    if (!res.ok) {
      throw new Error(await res.text())
    }
    return await res.json()
  }

  /*
    Simple helper to select form elements
    when other elements are clicked.
  */
  function selectRelatedInput(elements) {
    if (!elements) return

    const nodes =
      elements instanceof NodeList || Array.isArray(elements)
        ? Array.from(elements)
        : [elements];

    nodes.forEach(function (element) {
      if (!element) return
      const targetSelector = element.getAttribute("data-input-select-target");
      if (!targetSelector) return
      const target = document.querySelector(targetSelector);
      if (!target) return

      const event =
        element.tagName.toLowerCase() === "select" ? "change" : "click";

      element.addEventListener(event, function () {
        if (target.type === "checkbox" || target.type === "radio") {
          target.checked = true;
        } else {
          target.focus();
        }
      });
    });
  }

  class SelectRelatedInput {
    connect() {
      selectRelatedInput(document.querySelectorAll("[data-input-select-target]"));
    }
  }

  const Module = (function () {
    const nestableContainerSelector = '[data-behavior="nestable"]';
    const sortableOptions = {
      animation: 150,
      draggable: ".dd-item",
      handle: ".dd-handle",
      fallbackOnBody: true,
      swapThreshold: 0.65,
      // 0 turns off SortableJS's "drop near an empty list" check. The .dd-nesting drop
      // zones in _nestable.scss decide nesting, so a vertical drag past an item's edge
      // does not nest it by accident.
      emptyInsertThreshold: 0,
      onStart: onStartHandler,
      onEnd: onEndHandler,
      onMove: onMoveHandler,
    };
    const draggableClass = "dd-item";
    const nestedSortableClass = "dd-list";
    const nestedSortableSelector = ".dd-list";
    const nestedSortableNodeName = "ol";
    const nestingClass = "dd-nesting";
    const findNode = (id, container) =>
      container.querySelector(`[data-id="${id}"]`);
    const setWeight = (node, weight) => (weightField(node).value = weight);
    const setParent = (node, parentId) => (parentPageField(node).value = parentId);
    const weightField = (node) => findProperty(node, "weight");
    const parentPageField = (node) => findProperty(node, "parent_page");
    const findProperty = (node, property) =>
      node.querySelector(`input[data-property="${property}"]`);
    let nestedId = 0;

    return {
      init: function (nestedContainers) {
        if (nestedContainers === undefined) {
          nestedContainers = document.querySelectorAll(nestableContainerSelector);
        }

        // nestedContainers is a list of DOM nodes, normalize to an array.
        const containersToInit = Array.from(nestedContainers);
        containersToInit.forEach((container) => {
          // Sir Trevor listens for drag and drop events and will error on Sortable events.
          // Don't let them bubble past the Sortable wrapper.
          container.addEventListener("drop", stopPropagationHandler);

          const nestedSortables = [
            ...(container.matches(nestedSortableSelector) ? [container] : []),
            ...Array.from(container.querySelectorAll(nestedSortableSelector)),
          ];
          const group = `nested-${nestedId++}`;

          nestedSortables.forEach((sortable) => {
            new Sortable(sortable, { ...sortableOptions, group: group });
          });
        });
      },
    }

    function stopPropagationHandler(evt) {
      evt.stopPropagation();
    }

    function onStartHandler(evt) {
      const nestableContainer = getNestableContainer(evt.item);
      makeEmptyChildSortablesForEligibleParents(
        nestableContainer,
        getMaxNestingLevelSetting(evt.item),
      );
      // Size the drop zone below each child list to match the dragged item, so that
      // a drag straight to the right lands in the list of the item above.
      nestableContainer.style.setProperty(
        "--dd-nesting-zone-height",
        `${evt.item.querySelector(sortableOptions.handle).offsetHeight}px`,
      );
      nestableContainer.classList.add(nestingClass);
    }

    function onEndHandler(evt) {
      const nestableContainer = getNestableContainer(evt.item);
      nestableContainer.classList.remove(nestingClass);
      removeEmptySortables(nestableContainer);
      updateWeightsAndRelationships(nestableContainer);
    }

    function onMoveHandler(evt) {
      // The usage of data-max-depth is one off of the standard notion of depth (# edges to root)
      // E.g., data-max-depth=2 allows for one level of nesting.
      // evt.dragged is a draggable in a Sortable (e.g., a dd-item)
      // evt.to is the Sortable to insert into (e.g., a dd-list)
      const maxAllowedDepth = getMaxNestingLevelSetting(evt.to) - 1;
      const newDepth = getSortableDepth(evt.to) + getHeight(evt.dragged);

      // Be careful here. Returning true is different than returning nothing in SortableJS.
      if (newDepth > maxAllowedDepth) {
        return false
      }
    }

    // Get the depth of the sortable element from the root container
    function getSortableDepth(sortableElement) {
      const originatingGroup = Sortable.get(sortableElement).options.group.name;
      let depth = 0;
      let parentSortableElement = sortableElement;

      while (
        (parentSortableElement = parentSortableElement.parentElement.closest(
          nestedSortableSelector,
        ))
      ) {
        const parentSortable = Sortable.get(parentSortableElement);
        if (parentSortable?.options.group.name === originatingGroup) {
          depth++;
        }
      }

      return depth
    }

    // Find the max child depth in the tree, starting from the draggableElement
    function findMaxDepth(draggableElement) {
      const childSortableElement = draggableElement.querySelector(
        nestedSortableSelector,
      );
      if (!childSortableElement) {
        return 1
      }

      const children = childSortableElement.querySelectorAll(`.${draggableClass}`);
      const childDepths = Array.from(children).map(findMaxDepth);
      return 1 + Math.max(0, ...childDepths)
    }

    function getHeight(draggableElement) {
      return findMaxDepth(draggableElement) - 1
    }

    function getNestableContainer(element) {
      return element.closest(nestableContainerSelector)
    }

    function getMaxNestingLevelSetting(element) {
      return getNestableContainer(element).getAttribute("data-max-depth") || 1
    }

    // Create empty child sortables for all potential parents as appropriate for the given nesting level
    function makeEmptyChildSortablesForEligibleParents(container, nestingLevel) {
      if (nestingLevel <= 1) {
        return
      }

      const sortableElement = container.querySelector(nestedSortableSelector);
      const sortable = Sortable.get(sortableElement);
      if (!sortable) {
        return
      }

      const group = sortable.options.group.name;
      const draggableElements = Array.from(sortableElement.children).filter(
        (child) => child.classList.contains(draggableClass),
      );

      draggableElements.forEach((draggableElement) => {
        if (!draggableElement.querySelector(nestedSortableSelector)) {
          const emptySortableElement = document.createElement(
            nestedSortableNodeName,
          );
          emptySortableElement.className = nestedSortableClass;
          draggableElement.appendChild(emptySortableElement);
          new Sortable(emptySortableElement, { ...sortableOptions, group: group });
        }
        makeEmptyChildSortablesForEligibleParents(
          draggableElement,
          nestingLevel - 1,
        );
      });
    }

    // Remove any empty sortables within the container. They could be empty lists, which are invalid for accessibility.
    function removeEmptySortables(container) {
      const sortableElements = container.querySelectorAll(nestedSortableSelector);
      sortableElements.forEach((sortableElement) => {
        if (sortableElement.innerHTML.trim() === "") {
          const sortable = Sortable.get(sortableElement);
          if (sortable) {
            sortable.destroy();
            sortableElement.remove();
          }
        }
      });
    }

    // Traverse all sortables within a container and update the weight and parent_page inputs
    function updateWeightsAndRelationships(container) {
      const sortableElement = container.matches(nestedSortableSelector)
        ? container
        : container.querySelector(nestedSortableSelector);
      const nestingLevelSetting = getMaxNestingLevelSetting(sortableElement);
      const sortable = Sortable.get(sortableElement);
      const stack = [{ nodes: sortable.toArray(), parentId: "" }];
      let weight = 0;

      while (stack.length > 0) {
        const { nodes, parentId } = stack.pop();

        nodes.forEach((nodeId) => {
          const node = findNode(nodeId, container);
          setWeight(node, weight++);

          if (nestingLevelSetting > 1) {
            setParent(node, parentId);
            const children = node.querySelector(nestedSortableSelector);
            if (children) {
              const sortableElement = Sortable.get(children);
              stack.push({ nodes: sortableElement.toArray(), parentId: nodeId });
            }
          }
        });
      }
    }
  })();

  // Bootstrap's ESM build exports Tab by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
  const Tab = bootstrap__namespace.Tab ?? bootstrap__namespace.default?.Tab;

  class Tabs {
    connect() {
      if (document.querySelector("[role=tabpanel]") && window.location.hash) {
        const targetId = window.location.hash.substring(1);
        const targetElement = document.getElementById(targetId);
        if (!targetElement) return

        const tabpanel = targetElement.closest("[role=tabpanel]");
        if (!tabpanel) return

        const tabElement = document.querySelector(
          `a[role=tab][href="#${tabpanel.id}"]`,
        );
        if (!tabElement) return

        Tab.getOrCreateInstance(tabElement).show();
      }
    }
  }

  // translationProgress is a plugin that updates the "3/14" progress
  // counters in the tabs of the translation adminstration dashboard.
  // This works by counting the number of progress items and translations
  // present (indicated by data attributes) in each tab's content
  class TranslationProgress {
    connect() {
      $('[data-behavior="translation-progress"]').each(function () {
        var currentTab = $(this);
        var tabName = $(this).attr("aria-controls");
        var translationFields = $("#" + tabName).find(
          '[data-translation-progress-item="true"]',
        );
        var completedTranslations = $("#" + tabName).find(
          '[data-translation-present="true"]',
        );

        currentTab
          .find("span")
          .text(completedTranslations.length + "/" + translationFields.length);
      });
    }
  }

  // Blacklight's BookmarkToggle is doing the real work, this only adds/removes the "blacklight-private" class.
  const VisibilityToggle = (e) => {
    if (e.target.matches('[data-checkboxsubmit-target="checkbox"]')) {
      const form = e.target.closest("form");
      if (form) {
        // Add/remove the "private" label to the document row when visibility is toggled
        const docRow = form.closest("tr");
        if (docRow) docRow.classList.toggle("blacklight-private");
      }
    }
  };
  document.addEventListener("click", VisibilityToggle);

  class Users {
    connect() {
      document
        .querySelectorAll(".edit_exhibit, .admin-users")
        .forEach((container) => {
          const edit_user = (event) => {
            event.preventDefault();
            const button = event.currentTarget;
            const row = button.closest("tr");
            row.style.display = "none";

            const id = button.getAttribute("data-target");
            // Show ALL rows for this id (the fields row and the actions row)
            container
              .querySelectorAll(`[data-edit-for='${id}']`)
              .forEach((edit_view) => {
                edit_view.style.display = "";

                // Cache original values in case editing is canceled
                edit_view
                  .querySelectorAll('input[type="text"], select')
                  .forEach((input) => {
                    input.dataset.orig = input.value;
                  });
              });
          };

          const cancel_edit = (event) => {
            event.preventDefault();
            const button = event.currentTarget;
            const id = button
              .closest("tr[data-edit-for]")
              .getAttribute("data-edit-for");

            // Hide all rows with this id
            container
              .querySelectorAll(`[data-edit-for='${id}']`)
              .forEach((edit_view) => {
                edit_view.style.display = "none";
                clear_errors(edit_view);
                rollback_changes(edit_view);
              });

            const show_view = container.querySelector(`[data-show-for='${id}']`);
            if (show_view) {
              show_view.style.display = "";
            }
          };

          const clear_errors = (element) => {
            element.querySelectorAll(".has-error").forEach((errorElement) => {
              errorElement.classList.remove("has-error");
              // Remove the error messages
              errorElement.querySelectorAll(".form-text").forEach((formText) => {
                formText.remove();
              });
            });
          };

          const rollback_changes = (element) => {
            element
              .querySelectorAll('input[type="text"], select')
              .forEach((input) => {
                if (input.dataset.orig !== undefined) {
                  input.value = input.dataset.orig;
                  input.dispatchEvent(new Event("change", { bubbles: true }));
                }
              });
          };

          const destroy_user = (event) => {
            const button = event.currentTarget;
            const id = button.getAttribute("data-target");
            const destroyInput = container.querySelector(
              `[data-destroy-for='${id}']`,
            );
            if (destroyInput) {
              destroyInput.value = "1";
            }
          };

          const new_user = (event) => {
            event.preventDefault();
            // Show ALL rows with data-edit-for='new'
            container
              .querySelectorAll(`[data-edit-for='new']`)
              .forEach((edit_view) => {
                edit_view.style.display = "";

                // Cache original values in case editing is canceled
                edit_view
                  .querySelectorAll('input[type="text"], select')
                  .forEach((input) => {
                    input.dataset.orig = input.value;
                  });
              });
          };

          const open_errors = () => {
            // Find all rows with errors within this container
            const allErrorElements = container.querySelectorAll(".has-error");
            const rowsToShow = new Set();

            allErrorElements.forEach((errorElement) => {
              const edit_row = errorElement.closest("[data-edit-for]");
              if (edit_row) {
                // Show all rows with the same data-edit-for value
                const id = edit_row.getAttribute("data-edit-for");
                container
                  .querySelectorAll(`[data-edit-for='${id}']`)
                  .forEach((row) => {
                    rowsToShow.add(row);
                  });
              }
            });

            rowsToShow.forEach((row) => {
              row.style.display = "";
            });
          };

          // First, hide all edit views
          container.querySelectorAll("[data-edit-for]").forEach((element) => {
            element.style.display = "none";
          });

          // Then show any with errors
          open_errors();

          // Attach event listeners
          container
            .querySelectorAll("[data-behavior='edit-user']")
            .forEach((button) => {
              button.addEventListener("click", edit_user);
            });

          container
            .querySelectorAll("[data-behavior='cancel-edit']")
            .forEach((button) => {
              button.addEventListener("click", cancel_edit);
            });

          container
            .querySelectorAll("[data-behavior='destroy-user']")
            .forEach((button) => {
              button.addEventListener("click", destroy_user);
            });

          container
            .querySelectorAll("[data-behavior='new-user']")
            .forEach((button) => {
              button.addEventListener("click", new_user);
            });
        });
    }
  }

  (function ($) {
  ((SirTrevor.BlockMixins.Autocompleteable = {
      mixinName: "Autocompleteable",
      preload: true,

      initializeAutocompleteable: function () {
        this.on("onRender", this.addAutocompletetoSirTrevorForm);

        if (this["autocomplete_url"] === undefined) {
          this.autocomplete_url = function () {
            return $("form[data-autocomplete-url]").data("autocomplete-url")
          };
        }

        if (this["autocomplete_fetch"] === undefined) {
          this.autocomplete_fetch = this.fetchAutocompleteResults;
        }

        if (this["transform_autocomplete_results"] === undefined) {
          this.transform_autocomplete_results = (val) => val;
        }

        if (this["highlight"] === undefined) {
          this.highlight = function (value) {
            if (!value) return ""
            const queryValue = this.getQueryValue().trim();
            return queryValue
              ? value.replace(new RegExp(queryValue, "gi"), "<strong>$&</strong>")
              : value
          };
        }

        if (this["autocomplete_control"] === undefined) {
          this.autocomplete_control = function () {
            const autocompleteID = this.autocompleteID();
            return `
          <auto-complete src="${this.autocomplete_url()}" for="${autocompleteID}-popup" fetch-on-empty>
            <input type="text" name="${autocompleteID}" placeholder="${i18n.t("blocks:autocompleteable:placeholder")}" data-default-typeahead>
            <ul id="${autocompleteID}-popup"></ul>
            <div id="${autocompleteID}-popup-feedback" class="visually-hidden"></div>
          </auto-complete>
        `
          };
        }

        if (this["autocomplete_element_template"] === undefined) {
          this.autocomplete_element_template = function (item) {
            return `<li role="option" data-autocomplete-value="${item.id}">${this.autocomplete_template(item)}</li>`
          };
        }
      },

      queryTokenizer: function (query) {
        return query.trim().toLowerCase().split(/\s+/).filter(Boolean)
      },

      filterResults: function (data, query) {
        const queryStrings = this.queryTokenizer(query);
        return data.filter((item) => {
          const lowerTitle = item.title.toLowerCase();
          return queryStrings.some((queryString) =>
            lowerTitle.includes(queryString),
          )
        })
      },

      fetchAutocompleteResults: async function (url) {
        const result = await fetchAutocompleteJSON(url);
        const transformed = this.transform_autocomplete_results(result);
        this.fetchedData = {};
        transformed.map((item) => (this.fetchedData[item.id] = item));
        return transformed
          .map((item) => this.autocomplete_element_template(item))
          .join("")
      },

      fetchOnceAndFilterLocalResults: async function (url) {
        if (this.fetchedData === undefined) {
          await this.fetchAutocompleteResults(url);
        }
        const query = url.searchParams.get("q");
        const data = Object.values(this.fetchedData);
        const filteredData = query ? this.filterResults(data, query) : data;
        return filteredData
          .map((item) => this.autocomplete_element_template(item))
          .join("")
      },

      autocompleteID: function () {
        return this.blockID + "-autocomplete"
      },

      getQueryValue: function () {
        const completer = this.inner.querySelector("auto-complete > input");
        return completer.value
      },

      addAutocompletetoSirTrevorForm: function () {
        const completer = this.inner.querySelector("auto-complete");
        completer.fetchResult = this.autocomplete_fetch.bind(this);
        completer.addEventListener("auto-complete-change", (e) => {
          const data = this.fetchedData[e.relatedTarget.value];
          if (e.relatedTarget.value && data) {
            e.value = e.relatedTarget.value = "";
            this.createItemPanel({ ...data, display: "true" });
          }
        });
      },
    }),
      SirTrevor.Block.prototype.availableMixins.push("autocompleteable"));
  })(jQuery);

  (function ($) {
  ((SirTrevor.BlockMixins.Formable = {
      mixinName: "Formable",
      preload: true,

      initializeFormable: function () {
        if (this["afterLoadData"] === undefined) {
          this["afterLoadData"] = function (_data) {};
        }
      },

      formId: function (id) {
        return this.blockID + "_" + id
      },

      _serializeData: function () {
        var data = $(":input,textarea,select", this.inner)
          .not(":input:radio")
          .serializeJSON();

        $(":input:radio:checked", this.inner).each(function (index, input) {
          var key = $(input).data("key") || input.getAttribute("name");

          if (!key.match("\\[")) {
            data[key] = $(input).val();
          }
        });

        /* Simple to start. Add conditions later */
        if (this.hasTextBlock()) {
          data.text = this.getTextBlockHTML();
          data.format = "html";
          if (
            data.text &&
            data.text.length > 0 &&
            this.options.convertToMarkdown
          ) {
            data.text = stToMarkdown(data.text, this.type);
            data.format = "markdown";
          }
        }

        return data
      },

      loadData: function (data) {
        if (this.hasTextBlock()) {
          if (
            data.text &&
            data.text.length > 0 &&
            this.options.convertFromMarkdown &&
            data.format !== "html"
          ) {
            this.setTextBlockHTML(SirTrevor.toHTML(data.text, this.type));
          } else {
            this.setTextBlockHTML(data.text);
          }
        }
        this.loadFormDataByKey(data);
        this.afterLoadData(data);
      },

      loadFormDataByKey: function (data) {
        $(":input", this.inner)
          .not("button,:input[type=hidden]")
          .each(function (index, input) {
            var key = $(input).data("key") || input.getAttribute("name");

            if (key) {
              if (key.match("\\[\\]$")) {
                key = key.replace("[]", "");
              }

              // by wrapping it in an array, this'll "just work" for radio and checkbox fields too
              var input_data = data[key];

              if (!(input_data instanceof Array)) {
                input_data = [input_data];
              }
              $(this).val(input_data);
            }
          });
      },
    }),
      SirTrevor.Block.prototype.availableMixins.push("formable"));
  })(jQuery);

  (function (_$) {
    SirTrevor.BlockMixins.Plustextable = {
      mixinName: "Textable",
      preload: true,

      initializeTextable: function () {
        if (this["formId"] === undefined) {
          this.withMixin(SirTrevor.BlockMixins.Formable);
        }

        if (this["show_heading"] === undefined) {
          this.show_heading = true;
        }
      },

      align_key: "text-align",
      text_key: "item-text",
      heading_key: "title",

      text_area: function () {
        return `
      <div class="row">
        <div class="col-md-8">
          <div class="form-group mb-3">
            ${this.heading()}
            <div class="field">
              <label for="${this.formId(this.text_key)}" class="col-form-label">${i18n.t("blocks:textable:text")}</label>
              <div id="${this.formId(this.text_key)}" class="st-text-block form-control" contenteditable="true"></div>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="text-align">
            <p>${i18n.t("blocks:textable:align:title")}</p>
            <input data-key="${this.align_key}" type="radio" name="${this.formId(this.align_key)}" id="${this.formId(this.align_key + "-left")}" value="left" checked="true">
            <label for="${this.formId(this.align_key + "-left")}">${i18n.t("blocks:textable:align:left")}</label>
            <input data-key="${this.align_key}" type="radio" name="${this.formId(this.align_key)}" id="${this.formId(this.align_key + "-right")}" value="right">
            <label for="${this.formId(this.align_key + "-right")}">${i18n.t("blocks:textable:align:right")}</label>
          </div>
        </div>
      </div>`
      },

      heading: function () {
        if (this.show_heading) {
          return `<div class="field">
          <label for="${this.formId(this.heading_key)}" class="col-form-label">${i18n.t("blocks:textable:heading")}</label>
          <input type="text" class="form-control" id="${this.formId(this.heading_key)}" name="${this.heading_key}" />
        </div>`
        } else {
          return ""
        }
      },
    };

    SirTrevor.Block.prototype.availableMixins.push("plustextable");
  })(jQuery);

  (function ($) {
    Spotlight$1.Block = SirTrevor.Block.extend({
      scribeOptions: {
        allowBlockElements: true,
        tags: { p: true },
      },
      formable: true,
      editorHTML: function () {
        return ""
      },
      beforeBlockRender: function () {
        this.availableMixins.forEach(function (mixin) {
          if (
            this[mixin] &&
            SirTrevor.BlockMixins[this.capitalize(mixin)].preload
          ) {
            this.withMixin(SirTrevor.BlockMixins[this.capitalize(mixin)]);
          }
        }, this);
      },
      instance: function () {
        return document.getElementById(this.instanceID)
      },
      capitalize: function (string) {
        return string.charAt(0).toUpperCase() + string.substring(1).toLowerCase()
      },
    });
  })(jQuery);

  Spotlight$1.Block.Resources = (function () {
    return Spotlight$1.Block.extend({
      type: "resources",
      formable: true,
      autocompleteable: true,
      show_heading: true,
      show_image_selection: true,
      title: function () {
        return i18n.t("blocks:" + this.type + ":title")
      },
      description: function () {
        return i18n.t("blocks:" + this.type + ":description")
      },
      alt_text_guidelines: function () {
        if (this.showAltText()) {
          return i18n.t("blocks:alt_text_guidelines:intro")
        }
        return ""
      },
      alt_text_guidelines_link: function () {
        if (this.showAltText()) {
          var link_url = i18n.t("blocks:alt_text_guidelines:link_url");
          var link_label = i18n.t("blocks:alt_text_guidelines:link_label");
          return (
            '<a target="_blank" href="' + link_url + '">' + link_label + "</a>"
          )
        }
        return ""
      },
      icon_name: "resources",
      blockGroup: function () {
        return i18n.t("blocks:group:items")
      },

      primary_field_key: "primary-caption-field",
      show_primary_field_key: "show-primary-caption",
      secondary_field_key: "secondary-caption-field",
      show_secondary_field_key: "show-secondary-caption",

      display_checkbox: "display-checkbox",
      decorative_checkbox: "decorative-checkbox",
      alt_text_textarea: "alt-text-textarea",

      globalIndex: 0,

      _itemPanelIiifFields: function (_index, _data) {
        return []
      },

      _altTextFieldsHTML: function (index, data) {
        if (this.showAltText()) {
          return this.altTextHTML(index, data)
        }
        return ""
      },

      showAltText: function () {
        return this.editorOptions.altTextSettings[this._typeAsCamelCase()]
      },

      _typeAsCamelCase: function () {
        return this.type
          .split("_")
          .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
          .join("")
      },
      _itemSelectImageLink: function (block_item_id, doc_id, index) {
        // If image selection is not possible for this block, then do not show
        // image selection link
        if (!this.show_image_selection) return ``
        var url =
          $("form[data-exhibit-path]").data("exhibit-path") + "/select_image?";
        var markup = `
          <a name="selectimage" href="${url}block_item_id=${block_item_id}&index_id=${index}" data-blacklight-modal="trigger">Select image area</a>
        `;
        return markup
      },
      _itemPanel: function (data) {
        var index = "item_" + this.globalIndex++;
        var checked;
        if (data.display == "true") {
          checked = "checked='checked'";
        } else {
          checked = "";
        }
        var resource_id = data.slug || data.id;
        var block_item_id = this.formId(index);
        var markup = `
          <li class="field dd-item dd3-item" data-cropper="select_image_${block_item_id}" data-resource-id="${resource_id}" data-id="${index}" id="${block_item_id}" data-input-prefix="item[${index}]">
            <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
            <input type="hidden" name="item[${index}][title]" value="${data.title}" />
            ${this._itemPanelIiifFields(index, data)}
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
              <div class="card d-flex dd3-content">
                <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
                <div class="card-header item-grid">
                  <div class="d-flex">
                    <div class="d-inline-block">
                      <div class="d-flex">
                        <div class="checkbox">
                          <input name="item[${index}][display]" type="hidden" value="false" />
                          <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + "_" + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                          <label class="visually-hidden" for="${this.formId(this.display_checkbox + "_" + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                        </div>
                        <div class="pic">
                          <img class="img-thumbnail" src="${data.thumbnail_image_url || (data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")}" />
                        </div>
                      </div>
                      <div class="d-inline-block">
                        ${this._itemSelectImageLink(block_item_id, data.id, index)}
                      </div>
                    </div>
                    <div class="main">
                      <div class="title card-title">${data.title}</div>
                      <div>${data.slug || data.id}</div>
                      ${this._altTextFieldsHTML(index, data)}
                    </div>
                    <div class="remove float-end">
                      <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                    </div>
                  </div>
                  <div data-panel-image-pagination="true"></div>
                </div>
              </div>
            </li>
      `;

        const panel = $(markup);
        var context = this;

        $(".remove a", panel).on("click", function (e) {
          e.preventDefault();
          $(this).closest(".field").remove();
          context.afterPanelDelete();
        });

        this.afterPanelRender(data, panel);

        return panel
      },

      afterPanelRender: function (_data, _panel) {},

      afterPanelDelete: function () {},

      createItemPanel: function (data) {
        var panel = this._itemPanel(data);
        this.attachAltTextHandlers(panel);
        $(panel).appendTo($(".panels > ol", this.inner));
        $('[data-behavior="nestable"]', this.inner).trigger("change");
      },

      item_options: function () {
        return ""
      },

      content: function () {
        var templates = [this.items_selector()];
        if (this.plustextable) {
          templates.push(this.text_area());
        }
        return templates.join("<hr />\n")
      },

      items_selector: function () {
        return [
          '<div class="row">',
          '<div class="col-md-8">',
          '<div class="form-group mb-3">',
          '<div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1"><ol class="dd-list"></ol></div>',
          this.autocomplete_control(),
          "</div>",
          "</div>",
          '<div class="col-md-4">',
          this.item_options(),
          "</div>",
          "</div>",
        ].join("\n")
      },

      editorHTML: function () {
        return `<div class="form resources-admin clearfix">
        <div class="widget-header">
          ${this.description()}
          ${this.alt_text_guidelines()}
          ${this.alt_text_guidelines_link()}
        </div>
        ${this.content()}
      </div>`
      },

      _altTextData: function (data) {
        const isDecorative = data.decorative;
        const altText = isDecorative ? "" : data.alt_text || "";
        const altTextBackup = data.alt_text_backup || "";
        const placeholderAttr = isDecorative
          ? ""
          : `placeholder="${i18n.t("blocks:resources:alt_text:placeholder")}"`;
        const disabledAttr = isDecorative ? "disabled" : "";

        return {
          isDecorative,
          altText,
          altTextBackup,
          placeholderAttr,
          disabledAttr,
        }
      },

      altTextHTML: function (index, data) {
        const {
          isDecorative,
          altText,
          altTextBackup,
          placeholderAttr,
          disabledAttr,
        } = this._altTextData(data);
        return `<div class="mt-2 pt-2 d-flex">
          <div class="me-2">
            <label class="col-form-label pb-0 pt-1" for="${this.formId(this.alt_text_textarea + "_" + data.id)}">${i18n.t("blocks:resources:alt_text:alternative_text")}</label>
            <div class="form-check mb-1 justify-content-end">
              <input class="form-check-input" type="checkbox"
                id="${this.formId(this.decorative_checkbox + "_" + data.id)}" name="item[${index}][decorative]" ${isDecorative ? "checked" : ""}>
              <label class="form-check-label" for="${this.formId(this.decorative_checkbox + "_" + data.id)}">${i18n.t("blocks:resources:alt_text:decorative")}</label>
            </div>
          </div>
          <div class="flex-grow-1 flex-fill d-flex">
            <input type="hidden" name="item[${index}][alt_text_backup]" value="${altTextBackup}" />
            <textarea class="form-control w-100" rows="2" ${placeholderAttr}
              id="${this.formId(this.alt_text_textarea + "_" + data.id)}" name="item[${index}][alt_text]" ${disabledAttr}>${altText}</textarea>
          </div>
        </div>`
      },

      attachAltTextHandlers: function (panel) {
        if (this.showAltText()) {
          const decorativeCheckbox = $('input[name$="[decorative]"]', panel);
          const altTextInput = $('textarea[name$="[alt_text]"]', panel);
          const altTextBackupInput = $('input[name$="[alt_text_backup]"]', panel);

          decorativeCheckbox.on("change", function () {
            const isDecorative = this.checked;
            if (isDecorative) {
              altTextBackupInput.val(altTextInput.val());
              altTextInput.val("");
            } else {
              altTextInput.val(altTextBackupInput.val());
            }
            altTextInput
              .prop("disabled", isDecorative)
              .attr(
                "placeholder",
                isDecorative
                  ? ""
                  : i18n.t("blocks:resources:alt_text:placeholder"),
              );
          });

          altTextInput.on("input", function () {
            $(this).data("lastValue", $(this).val());
          });
        }
      },

      onBlockRender: function () {
        Module.init(
          this.inner.querySelectorAll('[data-behavior="nestable"]'),
        );
        selectRelatedInput(
          this.inner.querySelectorAll("[data-input-select-target]"),
        );
      },

      afterLoadData: function (data) {
        var context = this;
        $.each(
          Object.keys(data.item || {})
            .map(function (k) {
              return data.item[k]
            })
            .sort(function (a, b) {
              return a.weight - b.weight
            }),
          function (index, item) {
            context.createItemPanel(item);
          },
        );
      },
    })
  })();

  SirTrevor.Blocks.Browse = (function () {
    return Spotlight$1.Block.Resources.extend({
      type: "browse",

      icon_name: "browse",

      autocomplete_url: function () {
        return this.instance().closest(
          "form[data-autocomplete-exhibit-searches-path]",
        ).dataset.autocompleteExhibitSearchesPath
      },

      autocomplete_fetch: function (url) {
        return this.fetchOnceAndFilterLocalResults(url)
      },

      autocomplete_template: function (obj) {
        const thumbnail = obj.thumbnail_image_url
          ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>`
          : "";
        const description = obj.description
          ? `<small>&nbsp;&nbsp;${obj.description}</small>`
          : "";
        return `<div class="autocomplete-item${!obj.published ? " blacklight-private" : ""}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.full_title)}</span>${description}</div>`
      },

      _itemPanel: function (data) {
        var index = "item_" + this.globalIndex++;
        var checked;
        if (data.display == "true") {
          checked = "checked='checked'";
        } else {
          checked = "";
        }
        var resource_id = data.slug || data.id;
        var markup = `
           <li class="field dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId(index)}">
            <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
            <input type="hidden" name="item[${index}][full_title]" value="${data.full_title || data.title}" />
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
              <div class="card d-flex dd3-content">
                <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
                <div class="card-header item-grid">
                  <div class="d-flex">
                    <div class="checkbox">
                      <input name="item[${index}][display]" type="hidden" value="false" />
                      <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + "_" + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                      <label class="visually-hidden" for="${this.formId(this.display_checkbox + "_" + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                    </div>
                    <div class="pic">
                      <img class="img-thumbnail" src="${data.thumbnail_image_url || (data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")}" />
                    </div>
                    <div class="main">
                      <div class="title card-title">${data.full_title || data.title}</div>
                      <div>${data.slug || data.id}</div>
                    </div>
                    <div class="remove float-end">
                      <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                    </div>
                  </div>
                </div>
              </div>
            </li>`;

        var panel = $(markup);
        var context = this;

        $(".remove a", panel).on("click", function (e) {
          e.preventDefault();
          $(this).closest(".field").remove();
          context.afterPanelDelete();
        });

        this.afterPanelRender(data, panel);

        return panel
      },

      item_options: function () {
        return `
      <label>
        <input type="hidden" name="display-item-counts" value="false" />
        <input type="checkbox" name="display-item-counts" value="true" checked />
        ${i18n.t("blocks:browse:item_counts")}
      </label>`
      },
    })
  })();

  /*
    Sir Trevor BrowseGroupCategories
  */

  SirTrevor.Blocks.BrowseGroupCategories = (function () {
    return Spotlight$1.Block.Resources.extend({
      type: "browse_group_categories",
      icon_name: "browse",

      autocomplete_control: function () {
        const autocompleteID = this.blockID + "-autocomplete";
        return `<auto-complete src="${this.autocomplete_url()}" for="${autocompleteID}-popup" fetch-on-empty>
        <input type="text" name="${autocompleteID}" placeholder="${i18n.t("blocks:browse_group_categories:autocomplete")}" data-default-typeahead>
        <ul id="${autocompleteID}-popup"></ul>
        <div id="${autocompleteID}-popup-feedback" class="visually-hidden"></div>
      </auto-complete>`
      },
      autocomplete_template: function (obj) {
        return `<div class="autocomplete-item${!obj.published ? " blacklight-private" : ""}">
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/></div>`
      },

      autocomplete_url: function () {
        return this.instance().closest(
          "form[data-autocomplete-exhibit-browse-groups-path]",
        ).dataset.autocompleteExhibitBrowseGroupsPath
      },
      autocomplete_fetch: function (url) {
        return this.fetchOnceAndFilterLocalResults(url)
      },
      _itemPanel: function (data) {
        var index = "item_" + this.globalIndex++;
        var checked;
        if (data.display == "true") {
          checked = "checked='checked'";
        } else {
          checked = "";
        }
        var resource_id = data.slug || data.id;
        var markup = `
        <li class="field dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId(index)}">
          <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
          <input type="hidden" name="item[${index}][title]" value="${data.title}" />
          <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
            <div class="card d-flex dd3-content">
              <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
              <div class="d-flex card-header item-grid justify-content-between">
                <div class="d-flex flex-grow-1">
                  <div class="checkbox">
                    <input name="item[${index}][display]" type="hidden" value="false" />
                    <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + "_" + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                    <label class="visually-hidden" for="${this.formId(this.display_checkbox + "_" + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                  </div>
                  <div class="main">
                    <div class="title card-title">${data.title}</div>
                  </div>
                </div>
                <div class="d-flex">
                  <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                </div>
              </div>
            </div>
          </li>`;

        const panel = $(markup);
        var context = this;

        $("a[data-item-grid-panel-remove]", panel).on("click", function (e) {
          e.preventDefault();
          $(this).closest(".field").remove();
          context.afterPanelDelete();
        });

        this.afterPanelRender(data, panel);

        return panel
      },

      item_options: function () {
        return `
      <label>
        <input type="hidden" name="display-item-counts" value="false" />
        <input type="checkbox" name="display-item-counts" value="true" checked />
        ${i18n.t("blocks:browse_group_categories:item_counts")}
      </label>`
      },
    })
  })();

  /*
    Sir Trevor ItemText Block.
    This block takes an ID,
    fetches the record from solr,
    displays the image, title, 
    and any provided text
    and displays them.
  */

  SirTrevor.Blocks.Iframe = (function () {
    return SirTrevor.Block.extend({
      type: "Iframe",
      formable: true,

      title: function () {
        return i18n.t("blocks:iframe:title")
      },
      description: function () {
        return i18n.t("blocks:iframe:description")
      },

      icon_name: "iframe",

      editorHTML: function () {
        return `<div class="clearfix">
        <div class="widget-header">
          ${this.description()}
        </div>
        <textarea name="code" class="form-control" rows="5" placeholder="${i18n.t("blocks:iframe:placeholder")}"></textarea>
      </div>`
      },
    })
  })();

  SirTrevor.Blocks.LinkToSearch = (function () {
    return SirTrevor.Blocks.Browse.extend({
      type: "link_to_search",

      icon_name: "search_results",

      searches_key: "slug",
      view_key: "view",
      plustextable: false,
    })
  })();

  /*
    Sir Trevor ItemText Block.
    This block takes an ID,
    fetches the record from solr,
    displays the image, title, 
    and any provided text
    and displays them.
  */

  SirTrevor.Blocks.Oembed = (function () {
    return Spotlight$1.Block.extend({
      plustextable: true,

      id_key: "url",

      type: "oembed",

      title: function () {
        return i18n.t("blocks:oembed:title")
      },
      description: function () {
        return i18n.t("blocks:oembed:description")
      },

      icon_name: "oembed",
      show_heading: false,

      editorHTML: function () {
        return `<div class="form oembed-text-admin clearfix">
      <div class="widget-header">
        ${this.description()}
      </div>
      <div class="row">
        <div class="form-group mb-3 col-md-8">
          <label for="${this.formId(this.id_key)}">${i18n.t("blocks:oembed:url")}</label>
          <input name="${this.id_key}" class="form-control col-md-6" type="text" id="${this.formId(this.id_key)}" />
        </div>
      </div>
      ${this.text_area()}
    </div>`
      },
    })
  })();

  SirTrevor.Blocks.FeaturedPages = (function () {
    return Spotlight$1.Block.Resources.extend({
      type: "featured_pages",

      icon_name: "pages",

      blockGroup: "undefined",

      show_image_selection: false,

      autocomplete_url: function () {
        return this.instance().closest(
          "form[data-autocomplete-exhibit-pages-path]",
        ).dataset.autocompleteExhibitPagesPath
      },
      autocomplete_fetch: function (url) {
        return this.fetchOnceAndFilterLocalResults(url)
      },
      autocomplete_template: function (obj) {
        const description = obj.description
          ? `<small>&nbsp;&nbsp;${obj.description}</small>`
          : "";
        const thumbnail = obj.thumbnail_image_url
          ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>`
          : "";
        return `<div class="autocomplete-item${!obj.published ? " blacklight-private" : ""}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/>${description}</div>`
      },
    })
  })();

  /*
    Sir Trevor ItemText Block.
    This block takes an ID,
    fetches the record from solr,
    displays the image, title, 
    and any provided text
    and displays them.
  */

  SirTrevor.Blocks.Rule = (function () {
    return SirTrevor.Block.extend({
      type: "rule",

      title: function () {
        return i18n.t("blocks:rule:title")
      },

      icon_name: "rule",

      editorHTML: function () {
        return "<hr />"
      },
    })
  })();

  SirTrevor.Blocks.SearchResults = (function () {
    return SirTrevor.Blocks.Browse.extend({
      type: "search_results",

      icon_name: "search_results",

      searches_key: "slug",
      view_key: "view",
      plustextable: false,

      content: function () {
        return this.items_selector()
      },

      item_options: function () {
        var block = this;
        var fields = $("[data-blacklight-configuration-search-views]").data(
          "blacklight-configuration-search-views",
        );

        return $.map(fields, function (field) {
          return `<div>
          <label for='${block.formId(block.view_key + field.key)}'>
            <input id='${block.formId(block.view_key + field.key)}' name='${block.view_key}[]' type='checkbox' value='${field.key}' />
          ${field.label}
          </label>
        </div>`
        }).join("\n")
      },

      afterPanelRender: function (_data, _panel) {
        $(this.inner).find(".item-input-field").attr("disabled", "disabled");
      },

      afterPanelDelete: function () {
        $(this.inner).find(".item-input-field").removeAttr("disabled");
      },
    })
  })();

  SirTrevor.Blocks.SolrDocumentsBase = (function () {
    return Spotlight$1.Block.Resources.extend({
      plustextable: true,
      autocomplete_url: function () {
        return this.instance().closest(
          "form[data-autocomplete-exhibit-catalog-path]",
        ).dataset.autocompleteExhibitCatalogPath
      },
      autocomplete_template: function (obj) {
        const thumbnail = obj.thumbnail
          ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>`
          : "";
        return `<div class="autocomplete-item${obj.private ? " blacklight-private" : ""}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/><small>&nbsp;&nbsp;${this.highlight(obj.description)}</small></div>`
      },
      transform_autocomplete_results: function (response) {
        return (response["docs"] || []).map(function (doc) {
          return doc
        })
      },

      caption_option_values: function () {
        const element = document.querySelector(
          "[data-blacklight-configuration-index-fields]",
        );
        const fieldsData = element
          ? element.dataset.blacklightConfigurationIndexFields
          : null;
        let fields = [];
        if (fieldsData) {
          try {
            fields = JSON.parse(fieldsData);
          } catch (e) {
            // ignore
          }
        }

        return fields
          .map(function (field) {
            return `<option value="${field.key}">${field.label}</option>`
          })
          .join("\n")
      },

      item_options: function () {
        return this.caption_options()
      },

      caption_options: function () {
        return `
      <div class="field-select primary-caption" data-behavior="item-caption-admin">
        <input name="${this.show_primary_field_key}" type="hidden" value="false" />
        <input data-input-select-target="#${this.formId(this.primary_field_key)}" name="${this.show_primary_field_key}" id="${this.formId(this.show_primary_field_key)}" type="checkbox" value="true" />
        <label for="${this.formId(this.show_primary_field_key)}">${i18n.t("blocks:solr_documents:caption:primary")}</label>
        <select data-input-select-target="#${this.formId(this.show_primary_field_key)}" name="${this.primary_field_key}" id="${this.formId(this.primary_field_key)}">
          <option value="">${i18n.t("blocks:solr_documents:caption:placeholder")}</option>
          ${this.caption_option_values()}
        </select>
      </div>
      <div class="field-select secondary-caption" data-behavior="item-caption-admin">
        <input name="${this.show_secondary_field_key}" type="hidden" value="false" />
        <input data-input-select-target="#${this.formId(this.secondary_field_key)}" name="${this.show_secondary_field_key}" id="${this.formId(this.show_secondary_field_key)}" type="checkbox" value="true" />
        <label for="${this.formId(this.show_secondary_field_key)}">${i18n.t("blocks:solr_documents:caption:secondary")}</label>
        <select data-input-select-target="#${this.formId(this.show_secondary_field_key)}" name="${this.secondary_field_key}" id="${this.formId(this.secondary_field_key)}">
        <option value="">${i18n.t("blocks:solr_documents:caption:placeholder")}</option>
          ${this.caption_option_values()}
        </select>
      </div>
    `
      },

      // Sets the first version of the IIIF information from autocomplete data.
      _itemPanelIiifFields: function (index, autocomplete_data) {
        var iiifFields = [
          '<input type="hidden" name="item[' +
            index +
            '][thumbnail_image_url]" value="' +
            (autocomplete_data.thumbnail_image_url ||
              autocomplete_data.thumbnail ||
              "") +
            '"/>',
          '<input type="hidden" name="item[' +
            index +
            '][full_image_url]" value="' +
            (autocomplete_data.full_image_url ||
              autocomplete_data.thumbnail_image_url ||
              autocomplete_data.thumbnail ||
              "") +
            '"/>',
          '<input type="hidden" name="item[' +
            index +
            '][iiif_tilesource]" value="' +
            (autocomplete_data.iiif_tilesource || "") +
            '"/>',
          '<input type="hidden" name="item[' +
            index +
            '][iiif_manifest_url]" value="' +
            (autocomplete_data.iiif_manifest_url || "") +
            '"/>',
          '<input type="hidden" name="item[' +
            index +
            '][iiif_canvas_id]" value="' +
            (autocomplete_data.iiif_canvas_id || "") +
            '"/>',
          '<input type="hidden" name="item[' +
            index +
            '][iiif_image_id]" value="' +
            (autocomplete_data.iiif_image_id || "") +
            '"/>',
        ];

        // The region input is required for widgets that enable image cropping but not otherwise
        if (this.show_image_selection) {
          iiifFields.push(
            '<input type="hidden" name="item[' +
              index +
              '][iiif_region]" value="' +
              (autocomplete_data.iiif_region || "") +
              '"/>',
          );
        }

        return iiifFields.join("\n")
      },
      // Overwrites the hidden inputs from _itemPanelIiifFields with data from the
      // manifest. Called by afterPanelRender - the manifest_data here is built
      // from canvases in the manifest, transformed by spotlight/admin/iiif.js in
      // the #images method.
      setIiifFields: function (panel, manifest_data, initialize) {
        const el = panel.jquery ? panel[0] : panel;
        if (!el) return

        const legacyThumbnailField = el.querySelector(
          '[name$="[thumbnail_image_url]"]',
        );
        const legacyFullField = el.querySelector('[name$="[full_image_url]"]');

        if (
          initialize &&
          legacyThumbnailField &&
          legacyThumbnailField.value.length > 0
        ) {
          return
        }

        if (legacyThumbnailField) legacyThumbnailField.value = "";
        if (legacyFullField) legacyFullField.value = "";

        const iiifImageIdField = el.querySelector('[name$="[iiif_image_id]"]');
        if (iiifImageIdField) iiifImageIdField.value = manifest_data.imageId || "";

        const iiifTilesourceField = el.querySelector(
          '[name$="[iiif_tilesource]"]',
        );
        if (iiifTilesourceField)
          iiifTilesourceField.value = manifest_data.tilesource || "";

        const iiifManifestUrlField = el.querySelector(
          '[name$="[iiif_manifest_url]"]',
        );
        if (iiifManifestUrlField)
          iiifManifestUrlField.value = manifest_data.manifest || "";

        const iiifCanvasIdField = el.querySelector('[name$="[iiif_canvas_id]"]');
        if (iiifCanvasIdField)
          iiifCanvasIdField.value = manifest_data.canvasId || "";

        const img = el.querySelector("img.img-thumbnail");
        if (img) {
          img.src =
            manifest_data.thumbnail_image_url ||
            (manifest_data.tilesource || "").replace(
              "/info.json",
              "/full/100,100/0/default.jpg",
            );
        }
      },
      afterPanelRender: function (data, panel) {
        const el = panel.jquery ? panel[0] : panel;
        if (!el) return

        var context = this;
        var manifestUrl = data.iiif_manifest || data.iiif_manifest_url;

        if (!manifestUrl) {
          const legacyThumbnailField = el.querySelector(
            '[name$="[thumbnail_image_url]"]',
          );
          if (legacyThumbnailField) {
            legacyThumbnailField.value =
              data.thumbnail_image_url || data.thumbnail || "";
          }
          const legacyFullField = el.querySelector('[name$="[full_image_url]"]');
          if (legacyFullField) {
            legacyFullField.value = data.full_image_url || "";
          }

          return
        }

        fetch(manifestUrl)
          .then(function (response) {
            return response.json()
          })
          .then(function (manifest) {
            var iiifManifest = new Iiif(manifestUrl, manifest);

            var thumbs = iiifManifest.imagesArray();

            if (!data.iiif_image_id) {
              context.setIiifFields(panel, thumbs[0], !!data.iiif_manifest_url);
            }

            if (thumbs.length > 1) {
              multiImageSelector(
                panel,
                thumbs,
                function (selectorImage) {
                  context.setIiifFields(panel, selectorImage, false);
                },
                data.iiif_image_id,
              );
            }
          });
      },
    })
  })();

  SirTrevor.Blocks.SolrDocuments = (function () {
    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      type: "solr_documents",

      icon_name: "items",

      item_options: function () {
        return this.caption_options() + this.zpr_option()
      },

      zpr_option: function () {
        return `
        <div>
        <input name="${this.zpr_key}" type="hidden" value="false" />
        <input name="${this.zpr_key}" id="${this.formId(this.zpr_key)}" data-key="${this.zpr_key}" type="checkbox" value="true" />
        <label for="${this.formId(this.zpr_key)}">${i18n.t("blocks:solr_documents:zpr:title")}</label>
        </div>
      `
      },

      zpr_key: "zpr_link",
    })
  })();

  // Bootstrap's ESM build exports Carousel by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
  const Carousel$1 = bootstrap__namespace.Carousel ?? bootstrap__namespace.default?.Carousel;

  SirTrevor.Blocks.SolrDocumentsCarousel = (function () {
    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      plustextable: false,
      type: "solr_documents_carousel",

      icon_name: "item_carousel",

      auto_play_images_key: "auto-play-images",
      auto_play_images_interval_key: "auto-play-images-interval",
      max_height_key: "max-height",

      carouselCycleTimesInSeconds: {
        values: [3, 5, 8, 12, 20],
        selected: 5,
      },

      carouselMaxHeights: {
        values: { Small: "small", Medium: "medium", Large: "large" },
        selected: "Medium",
      },

      item_options: function () {
        return `${this.caption_options()}
        <div class="field-select auto-cycle-images" data-behavior="auto-cycle-images">
          <input name="${this.auto_play_images_key}" type="hidden" value="false" />
          <input name="${this.auto_play_images_key}" id="${this.formId(this.auto_play_images_key)}" data-key="${this.auto_play_images_key}" type="checkbox" value="true" checked/>
          <label for="${this.formId(this.auto_play_images_key)}">${i18n.t("blocks:solr_documents_carousel:interval:title")}</label>
          <select name="${this.auto_play_images_interval_key}" id="${this.formId(this.auto_play_images_interval_key)}" data=key="${this.auto_play_images_interval_key}">
            <option value="">${i18n.t("blocks:solr_documents_carousel:interval:placeholder")}</option>
            ${this.addCarouselCycleOptions(this.carouselCycleTimesInSeconds)}
          </select>
        </div>
        <div class="field-select max-heights" data-behavior="max-heights">
          <label for="${this.formId(this.max_height_key)}">${i18n.t("blocks:solr_documents_carousel:height:title")}</label><br/>
          ${this.addCarouselMaxHeightOptions(this.carouselMaxHeights)}
        </div>`
      },

      addCarouselCycleOptions: function (options) {
        var html = "";

        $.each(options.values, function (index, interval) {
          var selected = interval === options.selected ? "selected" : "",
            intervalInMilliSeconds = parseInt(interval, 10) * 1000;

          html +=
            '<option value="' +
            intervalInMilliSeconds +
            '" ' +
            selected +
            ">" +
            interval +
            " seconds</option>";
        });

        return html
      },

      addCarouselMaxHeightOptions: function (options) {
        var html = "",
          _this = this;

        $.each(options.values, function (size, px) {
          var checked = size === options.selected ? "checked" : "",
            id = _this.formId(_this.max_height_key);

          html +=
            '<input data-key="' +
            _this.max_height_key +
            '" type="radio" name="' +
            id +
            '" value="' +
            px +
            '" id="' +
            id +
            '" ' +
            checked +
            ">";
          html +=
            '<label class="carousel-size" for="' + id + '">' + size + "</label>";
        });

        return html
      },

      afterPreviewLoad: function (options) {
        const carousels = this.inner.querySelectorAll(".carousel");

        const clickHandler = function (e) {
          const button = e.currentTarget;
          let target;
          try {
            const targetSelector =
              button.getAttribute("data-bs-target") || button.getAttribute("href");
            if (targetSelector) {
              target = document.querySelector(targetSelector);
            }
          } catch (err) {
            // ignore selector errors
          }

          if (!target) {
            target = button.closest(".carousel");
          }

          if (!target || !target.classList.contains("carousel")) return

          const carousel = Carousel$1.getOrCreateInstance(target);
          const slideIndex = button.getAttribute("data-bs-slide-to");

          if (slideIndex !== null) {
            carousel.to(parseInt(slideIndex, 10));
          } else {
            const slideAction = button.getAttribute("data-bs-slide");
            if (slideAction === "next") {
              carousel.next();
            } else if (slideAction === "prev") {
              carousel.prev();
            }
          }

          e.preventDefault();
        };

        carousels.forEach(function (carouselEl) {
          Carousel$1.getOrCreateInstance(carouselEl);

          carouselEl
            .querySelectorAll("[data-bs-slide], [data-bs-slide-to]")
            .forEach(function (btn) {
              btn.addEventListener("click", clickHandler);
            });
        });
      },
    })
  })();

  SirTrevor.Blocks.SolrDocumentsEmbed = (function () {
    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      type: "solr_documents_embed",
      icon_name: "item_embed",
      show_image_selection: false,

      item_options: function () {
        return ""
      },

      afterPreviewLoad: function (_options) {
        this.inner.querySelector("picture[data-openseadragon]").openseadragon();
      },
    })
  })();

  // Bootstrap's ESM build exports Carousel by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
  const Carousel = bootstrap__namespace.Carousel ?? bootstrap__namespace.default?.Carousel;

  SirTrevor.Blocks.SolrDocumentsFeatures = (function () {
    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      plustextable: false,
      type: "solr_documents_features",

      icon_name: "item_features",

      afterPreviewLoad: function (_options) {
        const carousels = this.inner.querySelectorAll(".carousel");

        const clickHandler = function (e) {
          const button = e.currentTarget;
          let target;
          try {
            const targetSelector =
              button.getAttribute("data-bs-target") || button.getAttribute("href");
            if (targetSelector) {
              target = document.querySelector(targetSelector);
            }
          } catch {
            // ignore selector errors
          }

          if (!target) {
            target = button.closest(".carousel");
          }

          if (!target || !target.classList.contains("carousel")) return

          const carousel = Carousel.getOrCreateInstance(target);
          const slideIndex = button.getAttribute("data-bs-slide-to");

          if (slideIndex !== null) {
            carousel.to(parseInt(slideIndex, 10));
          } else {
            const slideAction = button.getAttribute("data-bs-slide");
            if (slideAction === "next") {
              carousel.next();
            } else if (slideAction === "prev") {
              carousel.prev();
            }
          }

          e.preventDefault();
        };

        carousels.forEach(function (carouselEl) {
          Carousel.getOrCreateInstance(carouselEl);

          carouselEl
            .querySelectorAll("[data-bs-slide-to]")
            .forEach(function (btn) {
              btn.addEventListener("click", clickHandler);
            });
        });
      },
    })
  })();

  SirTrevor.Blocks.SolrDocumentsGrid = (function () {
    return SirTrevor.Blocks.SolrDocumentsBase.extend({
      type: "solr_documents_grid",

      icon_name: "item_grid",

      item_options: function () {
        return ""
      },
    })
  })();

  SirTrevor.Blocks.UploadedItems = (function () {
    return Spotlight$1.Block.Resources.extend({
      plustextable: true,
      uploadable: true,
      autocompleteable: false,
      show_image_selection: false,

      id_key: "file",

      type: "uploaded_items",

      icon_name: "items",

      blockGroup: "undefined",

      // Clear out the default Uploadable upload options
      // since we will be using our own custom controls
      upload_options: { html: "" },

      fileInput: function () {
        return this.inner.querySelector('input[type="file"]')
      },

      onBlockRender: function () {
        Module.init(
          this.inner.querySelectorAll('[data-behavior="nestable"]'),
        );

        const input = this.fileInput();
        if (input) {
          input.addEventListener("change", (ev) => {
            this.onDrop(ev.currentTarget);
          });
        }
      },

      onDrop: function (transferData) {
        var file = transferData.files[0];
          typeof URL !== "undefined"
              ? URL
              : typeof webkitURL !== "undefined"
                ? webkitURL
                : null;

        // Handle one upload at a time
        if (/image/.test(file.type)) {
          this.loading();

          this.uploader(
            file,
            (data) => {
              this.createItemPanel(data);
              const input = this.fileInput();
              if (input) {
                input.value = "";
              }
              this.ready();
            },
            () => {
              this.addMessage(i18n.t("blocks:image:upload_error"));
              this.ready();
            },
          );
        }
      },

      title: function () {
        return i18n.t("blocks:uploaded_items:title")
      },
      description: function () {
        return i18n.t("blocks:uploaded_items:description")
      },

      globalIndex: 0,

      _itemPanel: function (data) {
        var index = "file_" + this.globalIndex++;
        var checked = 'checked="checked"';

        if (data.display == "false") {
          checked = "";
        }

        var dataId = data.id || data.uid;
        var dataTitle = data.title || data.name;
        var dataUrl = data.url || data.file.url;

        var markup = `
          <li class="field dd-item dd3-item" data-id="${index}" id="${this.formId(index)}">
            <input type="hidden" name="item[${index}][id]" value="${dataId}" />
            <input type="hidden" name="item[${index}][title]" value="${dataTitle}" />
            <input type="hidden" name="item[${index}][url]" data-item-grid-thumbnail="true"  value="${dataUrl}"/>
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
            <div class="card d-flex dd3-content">
              <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
              <div class="card-header d-flex item-grid">
                <div class="checkbox">
                  <input name="item[${index}][display]" type="hidden" value="false" />
                  <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + "_" + dataId)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                  <label class="visually-hidden" for="${this.formId(this.display_checkbox + "_" + dataId)}">${i18n.t("blocks:resources:panel:display")}</label>
                </div>
                <div class="pic">
                  <img class="img-thumbnail" src="${dataUrl}" />
                </div>
                <div class="main form-horizontal">
                  <div class="title card-title">${dataTitle}</div>
                  <div class="field row me-3">
                    <label for="${this.formId("caption_" + dataId)}" class="col-form-label col-md-3">${i18n.t("blocks:uploaded_items:caption")}</label>
                    <input type="text" class="form-control col" id="${this.formId("caption_" + dataId)}" name="item[${index}][caption]" data-field="caption"/>
                  </div>
                  <div class="field row me-3">
                    <label for="${this.formId("link_" + dataId)}" class="col-form-label col-md-3">${i18n.t("blocks:uploaded_items:link")}</label>
                    <input type="text" class="form-control col" id="${this.formId("link_" + dataId)}" name="item[${index}][link]" data-field="link"/>
                  </div>
                  ${this._altTextFieldsHTML(index, data)}
                </div>
                <div class="remove float-end">
                  <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                </div>
              </div>
            </li>`;

        const tempDiv = document.createElement("div");
        tempDiv.innerHTML = markup.trim();
        const panel = tempDiv.firstElementChild;

        const captionInput = panel.querySelector('[data-field="caption"]');
        if (captionInput) {
          captionInput.value = data.caption || "";
        }
        const linkInput = panel.querySelector('[data-field="link"]');
        if (linkInput) {
          linkInput.value = data.link || "";
        }

        const removeBtn = panel.querySelector(".remove a");
        if (removeBtn) {
          removeBtn.addEventListener("click", (e) => {
            e.preventDefault();
            panel.remove();
            this.afterPanelDelete();
          });
        }

        this.afterPanelRender(data, panel);

        return panel
      },

      editorHTML: function () {
        return `<div class="form oembed-text-admin clearfix">
        <div class="widget-header">
          ${this.description()}
          ${this.alt_text_guidelines()}
          ${this.alt_text_guidelines_link()}
        </div>
        <div class="row">
          <div class="form-group mb-3 col-md-8">
            <div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">
              <ol class="dd-list">
              </ol>
            </div>
            <input type="file" id="uploaded_item_url" name="file[file_0][file_data]" />
          </div>
          <div class="col-md-4">
            <input name="${this.zpr_key}" type="hidden" value="false" />
            <input name="${this.zpr_key}" id="${this.formId(this.zpr_key)}" data-key="${this.zpr_key}" type="checkbox" value="true" />
            <label for="${this.formId(this.zpr_key)}">${i18n.t("blocks:solr_documents:zpr:title")}</label>
          </div>
        </div>
        ${this.text_area()}
      </div>`
      },

      altTextHTML: function (index, data) {
        const {
          isDecorative,
          altText,
          altTextBackup,
          placeholderAttr,
          disabledAttr,
        } = this._altTextData(data);
        return `
      <div class="field row me-3">
        <div class="col-lg-3 ps-md-2">
          <label class="col-form-label text-nowrap pb-0 pt-1 justify-content-md-start justify-content-lg-end d-flex" for="${this.formId(this.alt_text_textarea + "_" + data.id)}">${i18n.t("blocks:resources:alt_text:alternative_text")}</label>
          <div class="form-check d-flex justify-content-md-start justify-content-lg-end">
            <input class="form-check-input" type="checkbox"
              id="${this.formId(this.decorative_checkbox + "_" + data.id)}" name="item[${index}][decorative]" ${isDecorative ? "checked" : ""}>
            <label class="form-check-label" for="${this.formId(this.decorative_checkbox + "_" + data.id)}">${i18n.t("blocks:resources:alt_text:decorative")}</label>
          </div>
        </div>
        <input type="hidden" name="item[${index}][alt_text_backup]" value="${altTextBackup}" />
        <textarea class="col-lg-9" rows="2" ${placeholderAttr}
          id="${this.formId(this.alt_text_textarea + "_" + data.id)}" name="item[${index}][alt_text]" ${disabledAttr}>${altText}</textarea>
      </div>`
      },

      zpr_key: "zpr_link",
    })
  })();

  (function () {
    var BLOCK_REPLACER_CONTROL_TEMPLATE = function (block) {
      var el = document.createElement("button");
      el.className = "st-block-controls__button";
      el.setAttribute("data-type", block.type);
      el.type = "button";

      var img = document.createElement("svg");
      img.className = "st-icon";
      img.setAttribute("role", "img");

      var use = document.createElement("use");
      use.setAttributeNS(
        "https://www.w3.org/1999/xlink",
        "href",
        SirTrevor.config.defaults.iconUrl + "#" + block.icon_name,
      );
      img.appendChild(use);
      el.appendChild(img);
      el.appendChild(document.createTextNode(block.title()));

      return el.outerHTML
    };

    function generateBlocksHTML(Blocks, availableTypes) {
      var groups = {};
      for (var i in availableTypes) {
        var type = availableTypes[i];
        if (
          Object.prototype.hasOwnProperty.call(Blocks, type) &&
          Blocks[type].prototype.toolbarEnabled
        ) {
          var blockGroup;

          if ($.isFunction(Blocks[type].prototype.blockGroup)) {
            blockGroup = Blocks[type].prototype.blockGroup();
          } else {
            blockGroup = Blocks[type].prototype.blockGroup;
          }

          if (blockGroup == "undefined" || blockGroup === undefined) {
            blockGroup = i18n.t("blocks:group:undefined");
          }

          groups[blockGroup] = groups[blockGroup] || [];
          groups[blockGroup].push(
            BLOCK_REPLACER_CONTROL_TEMPLATE(Blocks[type].prototype),
          );
        }
      }

      function generateBlock(groups, key) {
        var group = groups[key];
        var groupEl = $(
          "<div class='st-controls-group'><div class='st-group-col-form-label'>" +
            key +
            "</div></div>",
        );
        var buttons = group.reduce(function (memo, btn) {
          return memo + btn
        }, "");
        groupEl.append(buttons);
        return groupEl[0].outerHTML
      }

      var standardWidgets = generateBlock(
        groups,
        i18n.t("blocks:group:undefined"),
      );

      var exhibitWidgets = Object.keys(groups)
        .map(function (key) {
          if (key !== i18n.t("blocks:group:undefined")) {
            return generateBlock(groups, key)
          }
        })
        .filter(function (element) {
          return element != null
        });

      var blocks = [standardWidgets].concat(exhibitWidgets).join("<hr />");
      return blocks
    }

    function render(_Blocks, _availableTypes) {
      var el = document.createElement("div");
      el.className = "st-block-controls__buttons";
      el.innerHTML = generateBlocksHTML.apply(null, arguments);

      var elButtons = document.createElement("div");
      elButtons.className = "spotlight-block-controls";
      elButtons.appendChild(el);
      return elButtons
    }

    Spotlight$1.BlockControls = function () {};
    Spotlight$1.BlockControls.create = function (editor) {
      // REFACTOR - should probably not know about blockManager
      var el = render(SirTrevor.Blocks, editor.blockManager.blockTypes);

      function hide() {
        var parent = el.parentNode;
        if (!parent) {
          return
        }
        parent.removeChild(el);
        parent.classList.remove("st-block--controls-active");
        return parent
      }

      function destroy() {
        // eslint-disable-next-line no-global-assign
        SirTrevor = null;
        el = null;
      }

      function insert(e) {
        e.stopPropagation();

        var parent = this.parentNode;
        if (!parent || hide() === parent) {
          return
        }
        $(".st-block__inner", parent).after(el);
        parent.classList.add("st-block--controls-active");
      }

      $(editor.wrapper).delegate(".st-block-replacer", "click", insert);
      $(editor.wrapper).delegate(".st-block-controls__button", "click", insert);

      return {
        el: el,
        hide: hide,
        destroy: destroy,
      }
    };
  })();

  Spotlight$1.BlockLimits = function (editor) {
    this.editor = editor;
  };

  Spotlight$1.BlockLimits.prototype.enforceLimits = function (editor) {
    this.addEditorCallbacks(editor);
    this.checkGlobalBlockTypeLimit()();
  };

  Spotlight$1.BlockLimits.prototype.addEditorCallbacks = function (_editor) {
    SirTrevor.EventBus.on("block:create:new", this.checkBlockTypeLimitOnAdd());
    SirTrevor.EventBus.on("block:remove", this.checkGlobalBlockTypeLimit());
  };

  Spotlight$1.BlockLimits.prototype.checkBlockTypeLimitOnAdd = function () {
    var editor = this.editor;

    return function (block) {
      var control = $(
        ".st-block-controls__button[data-type='" + block.type + "']",
        editor.blockControls.el,
      );

      control.prop("disabled", !editor.blockManager.canCreateBlock(block.class()));
    }
  };

  Spotlight$1.BlockLimits.prototype.checkGlobalBlockTypeLimit = function () {
    // we don't know what type of block was created or removed.. So, try them all.
    var editor = this.editor;

    return function () {
      $.each(editor.blockManager.blockTypes, function (i, type) {
        var block_type = SirTrevor.Blocks[type].prototype;

        var control = $(editor.blockControls.el).find(
          ".st-block-controls__button[data-type='" + block_type.type + "']",
        );
        control.prop("disabled", !editor.blockManager.canCreateBlock(type));
      });
    }
  };

  SirTrevor.Locales.en.blocks = $.extend(SirTrevor.Locales.en.blocks, {
    autocompleteable: {
      placeholder: "Enter a title...",
    },

    browse: {
      title: "Browse Categories",
      description:
        "This widget highlights browse categories. Each highlighted category links to the corresponding browse category results page.",
      item_counts: "Include item counts?",
    },

    browse_group_categories: {
      autocomplete: "Enter a browse group title...",
      title: "Browse Group Categories",
      description:
        "This widget displays a limited number of browse categories from each selected browse group, with a link to view all categories in the group. Each selected group is displayed as a separate row. Each category links to the corresponding browse category results page.",
      item_counts: "Include category item counts?",
    },

    link_to_search: {
      title: "Saved Searches",
      description:
        "This widget highlights saved searches. Each highlighted saved search links to the search results page generated by the saved search parameters. Any saved search listed on the Curation > Browse categories page, whether published or not, can be highlighted as a saved search.",
      item_counts: "Include item counts?",
    },

    iframe: {
      title: "IFrame",
      description: "This widget embeds iframe-based embed code into pages",
      placeholder: "Enter embed code here. It should begin with e.g. '<iframe'",
    },

    oembed: {
      title: "Embed + Text",
      description:
        "This widget embeds an oEmbed-supported web resource and a text block to the left or right of it. Examples of oEmbed-supported resources include those from YouTube, Twitter, Flickr, and SlideShare.",
      url: "URL",
    },

    uploaded_items: {
      title: "Uploaded Item Row",
      description:
        "This widget displays uploaded items in a horizontal row. Optionally, you can add a heading and/or text to be displayed adjacent to the items. The item caption and link URL fields are also optional.",
      caption: "Caption",
      link: "Link URL",
    },

    featured_pages: {
      title: "Pages",
      description:
        "This widget highlights pages from this exhibit. Each highlighted item links to the corresponding page.",
    },

    resources: {
      panel: {
        drag: "Drag",
        display: "Display?",
        remove: "Remove",
      },
      alt_text: {
        decorative: "Decorative",
        alternative_text: "Alternative text",
        placeholder: "Enter alt text for this item...",
      },
    },

    rule: {
      title: "Horizontal Rule",
    },

    search_results: {
      title: "Search Results",
      description:
        "This widget displays a set of search results on a page. Specify a search result set by selecting an existing browse category. You can also select the view types that are available to the user when viewing the result set.",
    },

    solr_documents: {
      title: "Item Row",
      description:
        "This widget displays exhibit items in a horizontal row. Optionally, you can add a heading and/or text to be displayed adjacent to the items.",
      caption: {
        placeholder: "Select...",
        primary: "Primary caption",
        secondary: "Secondary caption",
      },
      zpr: {
        title: 'Offer "View larger" option',
      },
    },

    solr_documents_carousel: {
      title: "Item Carousel",
      description:
        "This widget displays exhibit items in a carousel. You can configure the item captions, how the images are cycled, and the size of the carousel.",
      interval: {
        title: "Automatically cycle images",
        placeholder: "Select...",
      },
      height: {
        title: "Maximum carousel height",
      },
    },

    solr_documents_embed: {
      title: "Item Embed",
      description:
        "This widget embeds an exhibit item in a viewer on a page. Optionally, you can add a heading to be displayed above the viewer and/or text to be displayed adjacent to the viewer.",
    },

    solr_documents_features: {
      title: "Item Slideshow",
      description:
        "This widget displays exhibit items in a static slideshow. The user will move between items in the slideshow using the field you select as the primary caption.",
    },

    solr_documents_grid: {
      title: "Item Grid",
      description:
        "This widget displays exhibit items in a multi-row grid. Optionally, you can add a heading and/or text to be displayed adjacent to the items.",
    },

    textable: {
      heading: "Heading",
      text: "Text",
      align: {
        title: "Display text on:",
        left: "Left",
        right: "Right",
      },
    },

    group: {
      undefined: "Standard widgets",
      items: "Exhibit item widgets",
    },

    alt_text_guidelines: {
      intro:
        "For each item, please enter alternative text or appropriately check the decorative box. ",
      link_label: "Guidelines for writing alt text.",
      link_url: "https://www.w3.org/WAI/tutorials/images/",
    },
  });

  class AdminIndex {
    connect() {
      new AddAnother().connect();
      new AddNewButton().connect();
      new Croppable().connect();
      new EditInPlace().connect();
      new Exhibits().connect();
      new FormObserver().connect();
      new Locks().connect();
      new BlacklightConfiguration().connect();
      new Pages().connect();
      new ProgressMonitor().connect();
      new ReadonlyCheckbox().connect();
      new SelectRelatedInput().connect();
      new Tabs().connect();
      new TranslationProgress().connect();
      new Users().connect();
      addAutocompletetoFeaturedImage();
      Module.init();
    }
  }

  // Connects to data-controller="clipboard"
  class ClipboardController extends stimulus.Controller {
    static targets = ["text"]

    async copy() {
      try {
        await navigator.clipboard.writeText(this.textTarget.innerText);
      } catch (err) {
        console.error("Clipboard controller failed to copy with error:", err);
      }
    }
  }

  class TagSelectorController extends stimulus.Controller {
    static targets = [
      "addNewTagWrapper",
      "dropdownContent",
      "initialTags",
      "newTag",
      "searchResultTags",
      "selectedTags",
      "tagControlWrapper",
      "tagSearch",
      "tagsField",
      "tagSearchDropdown",
      "tagSearchInputWrapper",
    ]

    static values = {
      tags: Array,
      translations: Object,
    }

    tagDropdown(_event) {
      this.dropdownContentTarget.classList.toggle("d-none");
    }

    clickOutside(event) {
      const isShown = !this.dropdownContentTarget.classList.contains("d-none");
      const inSelected = event.target.classList.contains("pill-close");
      const inContainer = this.tagControlWrapperTarget.contains(event.target);
      if (!inContainer && !inSelected && isShown) {
        this.tagDropdown(event);
      }
    }

    handleKeydown(event) {
      if (event.key === "Enter") {
        event.preventDefault();
        const hidden = this.dropdownContentTarget.classList.contains("d-none");
        if (hidden) return

        const tagElementToAdd =
          this.dropdownContentTarget.querySelector(".active")?.firstElementChild;
        if (tagElementToAdd) tagElementToAdd.click();
      }

      if (event.key === ",") {
        event.preventDefault();
        if (this.tagSearchTarget.value.length === 0) return

        if (!this.addNewTagWrapperTarget.classList.contains("d-none")) {
          this.addNewTagWrapperTarget.click();
          this.tagSearchTarget.focus();
          return
        }

        const exactMatch =
          this.dropdownContentTarget.querySelector(".active")?.firstElementChild;
        if (exactMatch?.checked === false) {
          exactMatch.click();
          this.resetSearch();
        }
        this.tagSearchTarget.focus();
      }
    }

    addNewTag(_event) {
      if (
        this.addNewTagWrapperTarget.classList.contains("d-none") ||
        this.newTagTarget.dataset.tag.length === 0
      ) {
        return
      }

      this.tagsValue = this.tagsValue.concat([this.newTagTarget.dataset.tag]);
      this.resetSearch();
    }

    resetSearch() {
      this.tagSearchTarget.value = "";
      this.newTagTarget.innerHTML = "";
      this.newTagTarget.dataset.tag = "";
      this.newTagTarget.disabled = true;
      this.addNewTagWrapperTarget.classList.add("d-none");
      this.searchResultTagsTargets.forEach((target) =>
        this.showElement(target.parentElement),
      );
    }

    tagUpdate(event) {
      const target = event.target ? event.target : event;
      if (target.checked) {
        this.tagsValue = this.tagsValue.concat([target.dataset.tag]);
      } else {
        this.tagsValue = this.tagsValue.filter(
          (tag) => tag !== target.dataset.tag,
        );
      }
    }

    updateSearchResultsPlaceholder(_event) {
      const placeholderElement =
        this.dropdownContentTarget.querySelector(".no-results");
      if (!placeholderElement) return

      const hasVisibleTags = this.dropdownContentTarget.querySelector(
        "label:not(.d-none):not(.no-results)",
      );
      placeholderElement.classList.toggle("d-none", hasVisibleTags);
    }

    tagCreate(event) {
      event.preventDefault();
      const newTagCheckbox = document.createElement("label");
      newTagCheckbox.innerHTML = `<input type="checkbox" checked data-action="click->${this.identifier}#tagUpdate" data-tag-selector-target="searchResultTags" data-tag="${this.newTagTarget.dataset.tag}"> ${this.newTagTarget.dataset.tag}`;
      const existingTags = Array.from(
        this.dropdownContentTarget.querySelectorAll(
          "label:not(#add-new-tag-wrapper)",
        ),
      );
      const insertPosition = existingTags.findIndex(
        (tag) =>
          tag.textContent.trim().localeCompare(this.newTagTarget.dataset.tag) > 0,
      );
      if (insertPosition === -1) {
        this.addNewTagWrapperTarget.insertAdjacentElement(
          "beforebegin",
          newTagCheckbox,
        );
      } else {
        existingTags[insertPosition].insertAdjacentElement(
          "beforebegin",
          newTagCheckbox,
        );
      }

      this.tagsValue = this.tagsValue.concat([this.newTagTarget.dataset.tag]);
      this.tagSearchTarget.value = "";
      this.tagSearchTarget.dispatchEvent(new Event("input"));
    }

    tagsValueChanged() {
      const isEmpty = this.tagsValue.length === 0;

      this.selectedTagsTarget.classList.toggle("d-none", isEmpty);
      this.tagSearchInputWrapperTarget.classList.toggle("rounded", isEmpty);
      this.tagSearchInputWrapperTarget.classList.toggle(
        "rounded-bottom",
        !isEmpty,
      );

      if (!isEmpty) {
        this.selectedTagsTarget.innerHTML = `<ul class="list-unstyled border rounded-top mb-0 p-1 px-2">${this.renderTagPills()}</ul>`;
      }

      const newValue = this.tagsValue.join(", ");
      if (this.tagsFieldTarget.value !== newValue) {
        this.tagsFieldTarget.value = newValue;
      }
    }

    normalizeTag(tag) {
      const normalizeRegex = /[^\w\s]/gi;
      return tag.replace(normalizeRegex, "").toLowerCase().trim()
    }

    showElement(element) {
      element.classList.add("d-block");
      element.classList.remove("d-none");
    }

    hideElement(element) {
      element.classList.remove("d-block");
      element.classList.add("d-none");
    }

    search(event) {
      const searchTerm = this.normalizeTag(event.target.value);
      this.dropdownContentTarget.classList.remove("d-none");

      const exactMatch = this.searchResultTagsTargets.some((target) => {
        const compareTerm = this.normalizeTag(target.dataset.tag);
        const isMatch = compareTerm.includes(searchTerm);
        target.parentElement.classList.remove("active");
        this[isMatch ? "showElement" : "hideElement"](target.parentElement);
        return compareTerm === searchTerm
      });

      this[searchTerm.length > 0 && !exactMatch ? "showElement" : "hideElement"](
        this.addNewTagWrapperTarget,
      );
      this.addNewTagWrapperTarget.classList.remove("active");
      this.dropdownContentTarget
        .querySelector("label:not(.d-none)")
        ?.classList.add("active");
    }

    updateTagToAdd(event) {
      const tagAlreadyAdded = this.tagsValue.some(
        (tag) => this.normalizeTag(tag) === this.normalizeTag(event.target.value),
      );
      this.newTagTarget.dataset.tag = event.target.value.trim();
      this.newTagTarget.nextSibling.textContent = ` ${this.translationsValue.add_new_tag}: ${event.target.value}`;
      this.newTagTarget.disabled =
        !this.newTagTarget.dataset.tag.length || tagAlreadyAdded;
    }

    deselect(event) {
      event.preventDefault();

      const clickedTag = event.target.closest("button").dataset.tag;
      const target = this.searchResultTagsTargets.find(
        (tag) => tag.dataset.tag === clickedTag,
      );
      target
        ? target.click()
        : (this.tagsValue = this.tagsValue.filter((tag) => tag !== clickedTag));
    }

    renderTagPills() {
      return this.tagsValue
        .map((tag) => {
          return `
        <li class="d-inline-flex gap-2 align-items-center my-2">
          <span class="bg-light badge rounded-pill border selected-item d-inline-flex align-items-center text-dark">
            <span class="selected-item-label d-inline-flex">${tag}</span>
            <button
              type="button"
              data-action="${this.identifier}#deselect"
              data-tag="${tag}"
              class="btn-close close ms-1"
              aria-label="${this.translationsValue.remove} ${tag}"
            ></button>
          </span>
        </li>
      `
        })
        .join("")
    }
  }

  class SpotlightControllers {
    connect() {
      if (typeof Stimulus === "undefined") return
      Stimulus.register("clipboard", ClipboardController);
      Stimulus.register("tag-selector", TagSelectorController);
    }
  }

  Spotlight$1.onLoad(() => {
    new SpotlightControllers().connect();
    new UserIndex().connect();
    new AdminIndex().connect();
  });

  return Spotlight$1;

}));
//# sourceMappingURL=spotlight.js.map
