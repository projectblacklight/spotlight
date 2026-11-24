// Embedded exhibit items for the WYSIWYG (Tiptap) page editor.
//
// An embed is stored as
//   <div data-spotlight-block="solr_documents_grid" data-spotlight-block-data="{...}"></div>
// where the data has the same shape as the corresponding SirTrevor widget's, so the
// server renders it with the SirTrevor block partials (see Spotlight::PageContent::Html).
// In the editor it's shown as a preview rendered by the server (the pages#preview action).
import Core from "spotlight/core"
import Iiif from "spotlight/admin/iiif"
import multiImageSelector from "spotlight/admin/multi_image_selector"
import { fetchAutocompleteJSON } from "spotlight/admin/search_typeahead"
import {
  EditorDialog,
  checkbox,
  field,
  select,
} from "spotlight/admin/html_editor_dialog"

// The display options each widget type supports (matching its SirTrevor block)
const TYPE_OPTIONS = {
  solr_documents: ["captions", "zpr"],
  solr_documents_grid: [],
  solr_documents_carousel: ["captions", "slideshow"],
  solr_documents_features: ["captions"],
  solr_documents_embed: [],
}
const INTERVALS = [3, 5, 8, 12, 20]
const MAX_HEIGHTS = ["small", "medium", "large"]

// "Visible text" plus text that's only for assistive technology (e.g. which item a control is for)
function setText(el, visible, hidden) {
  const visibleEl = document.createElement("span")
  visibleEl.textContent = visible
  const hiddenEl = document.createElement("span")
  hiddenEl.className = "visually-hidden"
  hiddenEl.textContent = hidden
  if (visible !== hidden.slice(0, visible.length))
    visibleEl.setAttribute("aria-hidden", "true")
  else hiddenEl.textContent = hidden.slice(visible.length)
  el.replaceChildren(visibleEl, hiddenEl)
}

// A label that's only for assistive technology (the control's purpose is visually clear)
function hiddenLabel(control, text) {
  const label = document.createElement("label")
  label.className = "visually-hidden"
  label.htmlFor = control.id
  label.textContent = text
  return label
}

function escapeHTML(value) {
  const div = document.createElement("div")
  div.textContent = value ?? ""
  return div.innerHTML
}

export function thumbnailFor(item) {
  return (
    item.thumbnail_image_url ||
    (item.iiif_tilesource || "").replace(
      "/info.json",
      "/full/!100,100/0/default.jpg",
    )
  )
}

const previewCache = new Map()

export function fetchPreview(previewUrl, type, data) {
  const block = JSON.stringify({ type, data })
  if (!previewCache.has(block)) {
    const body = new FormData()
    body.append("block", block)
    const request = fetch(previewUrl, {
      method: "POST",
      body,
      credentials: "same-origin",
      headers: { "X-CSRF-Token": Core.csrfToken() || "", Accept: "text/html" },
    }).then((response) => {
      if (!response.ok) throw new Error(`Preview failed (${response.status})`)
      return response.text()
    })
    request.catch(() => previewCache.delete(block))
    previewCache.set(block, request)
  }
  return previewCache.get(block)
}

// The editor node for an embedded widget. `options`:
//   labels, embedTypes ({type, label, ...}), previewUrl,
//   onEdit(pos): called to edit the embed at `pos`
export function spotlightEmbed(Node) {
  return Node.create({
    name: "spotlightEmbed",
    // Embeds can only be at the top level of the page (see the Document extension in html_editor.js)
    group: "spotlightEmbed",
    atom: true,
    draggable: true,
    selectable: true,

    addOptions() {
      return { labels: {}, embedTypes: [], previewUrl: null, onEdit: null }
    },

    addAttributes() {
      return {
        type: {
          default: null,
          parseHTML: (el) => el.getAttribute("data-spotlight-block"),
          renderHTML: (attrs) => ({ "data-spotlight-block": attrs.type }),
        },
        data: {
          default: {},
          parseHTML: (el) => {
            try {
              return JSON.parse(
                el.getAttribute("data-spotlight-block-data") || "{}",
              )
            } catch {
              return {}
            }
          },
          renderHTML: (attrs) => ({
            "data-spotlight-block-data": JSON.stringify(attrs.data || {}),
          }),
        },
      }
    },

    parseHTML() {
      return [{ tag: "div[data-spotlight-block]" }]
    },

    renderHTML({ HTMLAttributes }) {
      return ["div", HTMLAttributes]
    },

    addNodeView() {
      const { labels, embedTypes, previewUrl } = this.options
      const onEdit = (pos) => this.options.onEdit?.(pos)

      return ({ node, getPos, editor }) => {
        const dom = document.createElement("div")
        dom.className = "html-editor-embed"
        dom.contentEditable = "false"

        const header = document.createElement("div")
        header.className = "html-editor-embed-header"
        const name = document.createElement("span")
        name.className = "html-editor-embed-name"
        const editButton = document.createElement("button")
        editButton.type = "button"
        editButton.className = "btn btn-sm btn-outline-primary"
        editButton.textContent = labels.embed_edit_button || "Edit"
        const removeButton = document.createElement("button")
        removeButton.type = "button"
        removeButton.className = "btn btn-sm btn-outline-danger"
        removeButton.textContent = labels.embed_remove_button || "Remove"
        header.append(name, editButton, removeButton)

        // A visual preview; inert, so its links can't be focused or followed while editing
        const preview = document.createElement("div")
        preview.className = "html-editor-embed-preview"
        preview.inert = true
        dom.append(header, preview)

        editButton.addEventListener("click", () => onEdit(getPos()))
        removeButton.addEventListener("click", () => {
          const pos = getPos()
          editor
            .chain()
            .focus()
            .deleteRange({ from: pos, to: pos + node.nodeSize })
            .run()
        })

        let rendered = null
        const render = () => {
          const typeLabel =
            embedTypes.find((t) => t.type === node.attrs.type)?.label ||
            node.attrs.type
          name.textContent = typeLabel
          editButton.setAttribute(
            "aria-label",
            `${labels.embed_edit_button || "Edit"}: ${typeLabel}`,
          )
          removeButton.setAttribute(
            "aria-label",
            `${labels.embed_remove_button || "Remove"}: ${typeLabel}`,
          )

          const key = JSON.stringify(node.attrs)
          if (key === rendered) return
          rendered = key
          preview.textContent = labels.embed_loading || "Loading preview…"
          if (!previewUrl) return
          fetchPreview(previewUrl, node.attrs.type, node.attrs.data)
            .then((html) => {
              if (rendered === key) preview.innerHTML = html
            })
            .catch(() => {
              if (rendered === key)
                preview.textContent =
                  labels.embed_preview_failed ||
                  "The preview could not be loaded."
            })
        }
        render()

        return {
          dom,
          update(updated) {
            if (updated.type !== node.type) return false
            node = updated
            render()
            return true
          },
          selectNode() {
            dom.classList.add("ProseMirror-selectednode")
          },
          deselectNode() {
            dom.classList.remove("ProseMirror-selectednode")
          },
          // Let the header's buttons handle their own events
          stopEvent: (event) => header.contains(event.target),
          ignoreMutation: () => true,
        }
      }
    },
  })
}

// Apply a IIIF image (from spotlight/admin/iiif) to an item, as SirTrevor's
// SolrDocumentsBase#setIiifFields does
function applyIiifImage(item, image) {
  item.thumbnail_image_url = ""
  item.full_image_url = ""
  item.iiif_image_id = image.imageId || ""
  item.iiif_tilesource = image.tilesource || ""
  item.iiif_manifest_url = image.manifest || ""
  item.iiif_canvas_id = image.canvasId || ""
}

function loadManifestImages(manifestUrl) {
  return fetch(manifestUrl)
    .then((response) => response.json())
    .then((manifest) => new Iiif(manifestUrl, manifest).imagesArray())
}

// A dialog for choosing a widget type, the items it displays, and its display options.
// `config`: { embedTypes, autocompleteUrl, captionFields: [{key, label}] }
export class EmbedDialog extends EditorDialog {
  constructor(labels, config) {
    super(labels, { className: "html-editor-embed-dialog" })
    this.config = config
    this.docs = new Map()
    this.build()
  }

  label(key, fallback) {
    return this.labels[key] || fallback
  }

  build() {
    const id = this.id
    const types = this.config.embedTypes

    this.typeSelect = select(
      `${id}-type`,
      types.map((t) => [t.type, t.label]),
    )
    const typeField = field(
      this.label("embed_type", "Display as"),
      this.typeSelect,
    )
    this.typeDescription = typeField.querySelector(".form-text")
    if (!this.typeDescription) {
      this.typeDescription = document.createElement("div")
      this.typeDescription.className = "form-text"
      this.typeDescription.id = `${id}-type-help`
      this.typeSelect.setAttribute("aria-describedby", this.typeDescription.id)
      typeField.append(this.typeDescription)
    }
    this.typeSelect.addEventListener("change", () => this.updateForType())

    this.body.append(typeField, this.buildItems(), this.buildOptions())
  }

  buildItems() {
    const id = this.id
    const section = document.createElement("fieldset")
    section.className = "mb-3"
    const legend = document.createElement("legend")
    legend.className = "form-label fs-6"
    legend.textContent = this.label("embed_items", "Items")

    this.itemList = document.createElement("ol")
    this.itemList.className = "html-editor-embed-items list-unstyled mb-2"

    const completer = document.createElement("auto-complete")
    completer.setAttribute("src", this.config.autocompleteUrl || "")
    completer.setAttribute("for", `${id}-popup`)
    this.searchInput = document.createElement("input")
    this.searchInput.type = "text"
    this.searchInput.className = "form-control"
    this.searchInput.id = `${id}-search`
    this.searchInput.dataset.embedTypeahead = "true"
    this.searchInput.placeholder = this.label(
      "embed_search",
      "Search for an item to add",
    )
    this.searchInput.setAttribute("aria-label", this.searchInput.placeholder)
    const popup = document.createElement("ul")
    popup.id = `${id}-popup`
    const feedback = document.createElement("div")
    feedback.id = `${id}-popup-feedback`
    feedback.className = "visually-hidden"
    completer.append(this.searchInput, popup, feedback)
    this.floatPopup(completer, popup)

    completer.fetchResult = async (url) => {
      const result = await fetchAutocompleteJSON(url)
      return (result.docs || [])
        .map((doc) => {
          this.docs.set(doc.id, doc)
          const thumbnail = doc.thumbnail
            ? `<div class="document-thumbnail"><img class="img-thumbnail" alt="" src="${escapeHTML(doc.thumbnail)}" /></div>`
            : ""
          return `<li role="option" data-autocomplete-value="${escapeHTML(doc.id)}">
            <div class="autocomplete-item${doc.private ? " blacklight-private" : ""}">${thumbnail}
              <span class="autocomplete-title">${escapeHTML(doc.title)}</span><br/>
              <small>&nbsp;&nbsp;${escapeHTML(doc.description)}</small>
            </div>
          </li>`
        })
        .join("")
    }
    completer.addEventListener("auto-complete-change", (event) => {
      // Only for a chosen search result (the event also fires for other value changes)
      const doc = this.docs.get(event.relatedTarget.value)
      if (!doc) return
      event.relatedTarget.value = ""
      this.addDocument(doc)
    })

    section.append(legend, this.itemList, completer)
    return section
  }

  // Show the search results above the dialog, rather than clipped by its scrolling content:
  // the results list is a popover (in the top layer, like the modal dialog itself),
  // positioned under the search input while <auto-complete> is open.
  floatPopup(completer, popup) {
    if (!popup.showPopover) return

    popup.setAttribute("popover", "manual")
    popup.classList.add("html-editor-autocomplete-popup")
    this.popup = popup

    const position = () => {
      const rect = this.searchInput.getBoundingClientRect()
      popup.style.top = `${rect.bottom + 2}px`
      popup.style.left = `${rect.left}px`
      popup.style.width = `${rect.width}px`
      popup.style.maxHeight = `${Math.max(160, window.innerHeight - rect.bottom - 16)}px`
    }
    const update = () => {
      const open = completer.hasAttribute("open") && this.dialog.open
      if (open) {
        position()
        if (!popup.matches(":popover-open")) popup.showPopover()
      } else {
        this.hidePopup()
      }
    }
    new MutationObserver(update).observe(completer, {
      attributes: true,
      attributeFilter: ["open"],
    })
    // Close the results when clicking elsewhere in the dialog (they'd otherwise stay open
    // over it after the input loses focus). The results are inside <auto-complete>.
    this.dialog.addEventListener("pointerdown", (event) => {
      if (completer.open && !completer.contains(event.target))
        completer.open = false
    })
    // Keep it under the input when the dialog's content scrolls or the window resizes
    this.dialog.addEventListener("scroll", update, true)
    window.addEventListener("resize", update)
  }

  hidePopup() {
    if (this.popup?.matches(":popover-open")) this.popup.hidePopover()
  }

  cleanup() {
    this.hidePopup()
  }

  buildOptions() {
    const id = this.id
    const options = document.createElement("div")
    this.optionSections = {}

    // Captions
    const captions = document.createElement("div")
    captions.className = "row mb-3"
    const captionFields = [
      ["", this.label("embed_caption_placeholder", "Select a field…")],
      ...(this.config.captionFields || []).map((f) => [f.key, f.label]),
    ]
    this.captions = {}
    ;["primary", "secondary"].forEach((which) => {
      const col = document.createElement("div")
      col.className = "col-sm-6"
      const show = checkbox(
        `${id}-show-${which}-caption`,
        this.label(`embed_${which}_caption`, `${which} caption`),
      )
      const fieldSelect = select(`${id}-${which}-caption-field`, captionFields)
      fieldSelect.classList.add("mt-1")
      // Choosing a field turns the caption on, like SirTrevor's select-related inputs
      fieldSelect.addEventListener("change", () => {
        show.input.checked = fieldSelect.value !== ""
      })
      col.append(
        show.wrapper,
        hiddenLabel(
          fieldSelect,
          this.label(`embed_${which}_caption_field`, `${which} caption field`),
        ),
        fieldSelect,
      )
      captions.append(col)
      this.captions[which] = { show: show.input, field: fieldSelect }
    })
    this.optionSections.captions = captions

    // "View larger" (zoom) link
    const zpr = checkbox(
      `${id}-zpr`,
      this.label("embed_zpr", 'Offer "View larger" option'),
    )
    zpr.wrapper.classList.add("mb-3")
    this.zprInput = zpr.input
    this.optionSections.zpr = zpr.wrapper

    // Slideshow (carousel) options
    const slideshow = document.createElement("div")
    slideshow.className = "row mb-3"
    const autoplay = checkbox(
      `${id}-autoplay`,
      this.label("embed_autoplay", "Automatically cycle images"),
    )
    this.autoplayInput = autoplay.input
    this.intervalSelect = select(
      `${id}-interval`,
      INTERVALS.map((seconds) => [
        String(seconds * 1000),
        this.label("embed_interval_seconds", "%{seconds} seconds").replace(
          "%{seconds}",
          seconds,
        ),
      ]),
    )
    this.intervalSelect.classList.add("mt-1")
    const autoplayCol = document.createElement("div")
    autoplayCol.className = "col-sm-6"
    autoplayCol.append(
      autoplay.wrapper,
      hiddenLabel(
        this.intervalSelect,
        this.label("embed_interval", "Time between images"),
      ),
      this.intervalSelect,
    )
    this.maxHeightSelect = select(
      `${id}-max-height`,
      MAX_HEIGHTS.map((size) => [
        size,
        this.label(`embed_max_height_${size}`, size),
      ]),
    )
    const heightCol = field(
      this.label("embed_max_height", "Maximum height"),
      this.maxHeightSelect,
    )
    heightCol.classList.add("col-sm-6")
    slideshow.append(autoplayCol, heightCol)
    this.optionSections.slideshow = slideshow

    options.append(captions, zpr.wrapper, slideshow)
    return options
  }

  get type() {
    return this.typeSelect.value
  }

  get typeConfig() {
    return this.config.embedTypes.find((t) => t.type === this.type) || {}
  }

  // Show the description, options, and alt text fields for the selected type
  updateForType() {
    const typeOptions = TYPE_OPTIONS[this.type] || []
    this.typeDescription.textContent = this.typeConfig.description || ""
    Object.entries(this.optionSections).forEach(([name, section]) => {
      section.hidden = !typeOptions.includes(name)
    })
    this.itemList
      .querySelectorAll("[data-alt-text]")
      .forEach((el) => (el.hidden = !this.typeConfig.alt_text))
  }

  // Add an item found by the search (an autocomplete document)
  addDocument(doc) {
    const item = {
      id: doc.id,
      title: doc.title,
      thumbnail_image_url: doc.thumbnail || "",
      full_image_url: doc.full_image_url || doc.thumbnail || "",
      iiif_tilesource: "",
      iiif_manifest_url: "",
      iiif_canvas_id: "",
      iiif_image_id: "",
      display: "true",
    }
    const row = this.addItemRow(item)
    if (doc.iiif_manifest) this.loadImages(row, item, doc.iiif_manifest, true)
    row.querySelector("[data-item-show]").focus()
  }

  // Load the item's IIIF images: use the first one for a newly added item, and
  // offer a choice of image if there's more than one
  loadImages(row, item, manifestUrl, isNew) {
    const session = this.session
    loadManifestImages(manifestUrl)
      .then((images) => {
        if (!this.isCurrent(session) || images.length === 0) return
        if (isNew || !item.iiif_image_id) {
          // Keep a stored thumbnail for items without a chosen image, as SirTrevor does
          if (isNew || !item.thumbnail_image_url) {
            applyIiifImage(item, images[0])
            this.updateThumbnail(row, item)
          }
        }
        if (images.length > 1) {
          multiImageSelector(
            row,
            images,
            (image) => {
              applyIiifImage(item, image)
              this.updateThumbnail(row, item)
            },
            item.iiif_image_id,
          )
        }
      })
      .catch((error) => console.warn("Could not load IIIF manifest", error))
  }

  updateThumbnail(row, item) {
    row.querySelector(".pic img").src = thumbnailFor(item)
  }

  addItemRow(item) {
    const id = `${this.id}-item-${this.itemList.children.length}-${Date.now()}`
    const title = item.title || item.id
    const row = document.createElement("li")
    row.className = "html-editor-embed-item card mb-2"
    row.item = item

    const header = document.createElement("div")
    header.className = "card-header"
    const main = document.createElement("div")
    main.className = "d-flex gap-3 align-items-start"

    const show = checkbox(`${id}-show`, this.label("embed_show", "Show"))
    show.input.checked = item.display !== "false"
    show.input.dataset.itemShow = "true"
    setText(
      show.wrapper.querySelector("label"),
      this.label("embed_show", "Show"),
      `${this.label("embed_show", "Show")}: ${title}`,
    )

    const pic = document.createElement("div")
    pic.className = "pic"
    const img = document.createElement("img")
    img.className = "img-thumbnail"
    img.alt = ""
    img.src = thumbnailFor(item)
    pic.append(img)

    const details = document.createElement("div")
    details.className = "flex-grow-1"
    const titleEl = document.createElement("div")
    titleEl.className = "fw-semibold"
    titleEl.textContent = title
    const idEl = document.createElement("div")
    idEl.className = "small text-body-secondary"
    idEl.textContent = item.id
    const pagination = document.createElement("div")
    pagination.dataset.panelImagePagination = "true"

    const altText = document.createElement("div")
    altText.className = "mt-2"
    altText.dataset.altText = "true"
    const altInput = document.createElement("textarea")
    altInput.className = "form-control"
    altInput.rows = 2
    altInput.id = `${id}-alt`
    altInput.dataset.itemAlt = "true"
    altInput.value = item.alt_text || ""
    const altLabel = document.createElement("label")
    altLabel.className = "form-label small mb-1"
    altLabel.htmlFor = altInput.id
    altLabel.textContent = `${this.label("embed_alt_text", "Alternative text")}: ${title}`
    const decorative = checkbox(
      `${id}-decorative`,
      this.label("embed_decorative", "Decorative"),
    )
    decorative.input.dataset.itemDecorative = "true"
    decorative.input.checked = !!item.decorative
    altInput.disabled = decorative.input.checked
    decorative.input.addEventListener("change", () => {
      altInput.disabled = decorative.input.checked
    })
    altText.append(altLabel, altInput, decorative.wrapper)
    altText.hidden = !this.typeConfig.alt_text

    details.append(titleEl, idEl, pagination, altText)

    const actions = document.createElement("div")
    actions.className = "btn-group-vertical btn-group-sm"
    actions.setAttribute("role", "group")
    const button = (text, labelKey, fallback, handler) => {
      const el = document.createElement("button")
      el.type = "button"
      el.className = "btn btn-outline-secondary"
      setText(el, text, `${this.label(labelKey, fallback)}: ${title}`)
      el.title = this.label(labelKey, fallback)
      el.addEventListener("click", handler)
      actions.append(el)
      return el
    }
    button("↑", "embed_move_up", "Move up", (event) => {
      if (row.previousElementSibling) row.previousElementSibling.before(row)
      event.currentTarget.focus()
    })
    button("↓", "embed_move_down", "Move down", (event) => {
      if (row.nextElementSibling) row.nextElementSibling.after(row)
      event.currentTarget.focus()
    })
    button("✕", "embed_remove", "Remove", () => {
      const next = row.nextElementSibling || row.previousElementSibling
      row.remove()
      ;(next?.querySelector("[data-item-show]") || this.searchInput).focus()
    })

    main.append(show.wrapper, pic, details, actions)
    header.append(main)
    row.append(header)
    this.itemList.append(row)
    return row
  }

  // Open the dialog. With `attrs` ({type, data}, an existing embed), edit it;
  // otherwise insert a new one. Resolves with {type, data} or null if cancelled.
  open({ attrs = null } = {}) {
    const editing = !!attrs
    const data = attrs?.data || {}
    this.typeSelect.value = attrs?.type || this.config.embedTypes[0]?.type
    this.itemList.replaceChildren()
    this.searchInput.value = ""
    ;["primary", "secondary"].forEach((which) => {
      this.captions[which].show.checked =
        data[`show-${which}-caption`] === "true"
      this.captions[which].field.value = data[`${which}-caption-field`] || ""
    })
    this.zprInput.checked = data.zpr_link === "true"
    this.autoplayInput.checked = data["auto-play-images"] !== "false"
    this.intervalSelect.value = data["auto-play-images-interval"] || "5000"
    this.maxHeightSelect.value = data["max-height"] || "medium"
    this.updateForType()

    const result = this.show({
      title: editing
        ? this.label("embed_edit", "Edit items")
        : this.label("embed_insert", "Add items"),
      submitLabel: editing
        ? this.label("embed_save", "Save")
        : this.label("embed_insert_button", "Insert"),
      focus: editing ? this.typeSelect : this.searchInput,
    })

    Object.values(data.item || {})
      .sort((a, b) => Number(a.weight) - Number(b.weight))
      .forEach((item) => {
        const copy = { ...item }
        const row = this.addItemRow(copy)
        if (copy.iiif_manifest_url)
          this.loadImages(row, copy, copy.iiif_manifest_url, false)
      })

    return result
  }

  submit() {
    const rows = Array.from(this.itemList.children)
    if (rows.length === 0) {
      this.setError(this.label("embed_no_items", "Add at least one item."))
      this.searchInput.focus()
      return
    }

    const type = this.type
    const typeOptions = TYPE_OPTIONS[type] || []
    const data = { item: {} }
    rows.forEach((row, index) => {
      const item = { ...row.item }
      item.weight = String(index)
      item.display = row.querySelector("[data-item-show]").checked
        ? "true"
        : "false"
      const decorative = row.querySelector("[data-item-decorative]").checked
      item.alt_text = decorative
        ? ""
        : row.querySelector("[data-item-alt]").value.trim()
      if (decorative) item.decorative = "on"
      else delete item.decorative
      data.item[`item_${index}`] = item
    })

    if (typeOptions.includes("captions")) {
      ;["primary", "secondary"].forEach((which) => {
        const { show, field } = this.captions[which]
        data[`show-${which}-caption`] = show.checked ? "true" : "false"
        data[`${which}-caption-field`] = field.value
      })
    }
    if (typeOptions.includes("zpr")) {
      data.zpr_link = this.zprInput.checked ? "true" : "false"
    }
    if (typeOptions.includes("slideshow")) {
      data["auto-play-images"] = this.autoplayInput.checked ? "true" : "false"
      data["auto-play-images-interval"] = this.intervalSelect.value
      data["max-height"] = this.maxHeightSelect.value
    }

    this.finish({ type, data })
  }
}
