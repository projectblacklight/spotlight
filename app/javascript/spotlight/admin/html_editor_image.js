// Image support for the WYSIWYG (Tiptap) page editor: an image node with size,
// alignment and alt text, a dialog for inserting/editing images, and uploads
// to the exhibit's attachments endpoint (the same one SirTrevor's image block uses).
import Core from "spotlight/core"

export const IMAGE_SIZES = ["small", "medium", "large", "full"]
export const IMAGE_ALIGNMENTS = ["center", "left", "right"]

// Image nodes are stored as <img src alt data-size data-align [data-decorative]>
export function spotlightImage(Image) {
  return Image.extend({
    addAttributes() {
      return {
        ...this.parent?.(),
        size: {
          default: "medium",
          parseHTML: (el) => el.getAttribute("data-size") || "medium",
          renderHTML: (attrs) => ({ "data-size": attrs.size }),
        },
        align: {
          default: "center",
          parseHTML: (el) => el.getAttribute("data-align") || "center",
          renderHTML: (attrs) => ({ "data-align": attrs.align }),
        },
        decorative: {
          default: false,
          parseHTML: (el) => el.getAttribute("data-decorative") === "true",
          renderHTML: (attrs) =>
            attrs.decorative ? { "data-decorative": "true", alt: "" } : {},
        },
      }
    },
  }).configure({ allowBase64: false })
}

export function uploadImage(file, endpoint) {
  const body = new FormData()
  body.append("attachment[file]", file)
  body.append("attachment[name]", file.name)

  return fetch(endpoint, {
    method: "POST",
    body,
    credentials: "same-origin",
    headers: {
      "X-CSRF-Token": Core.csrfToken() || "",
      Accept: "application/json",
    },
  })
    .then((response) => {
      if (!response.ok) throw new Error(`Upload failed (${response.status})`)
      return response.json()
    })
    .then((json) => {
      if (!json.url) throw new Error("Upload response did not include a URL")
      return json.url
    })
}

let dialogCounter = 0

function field(labelText, control, help) {
  const wrapper = document.createElement("div")
  wrapper.className = "mb-3"
  const label = document.createElement("label")
  label.className = "form-label"
  label.textContent = labelText
  label.htmlFor = control.id
  wrapper.append(label, control)
  if (help) {
    const helpEl = document.createElement("div")
    helpEl.className = "form-text"
    helpEl.id = `${control.id}-help`
    helpEl.textContent = help
    control.setAttribute("aria-describedby", helpEl.id)
    wrapper.append(helpEl)
  }
  return wrapper
}

function select(id, name, values, labels) {
  const el = document.createElement("select")
  el.className = "form-select"
  el.id = id
  el.name = name
  values.forEach((value) => {
    const option = document.createElement("option")
    option.value = value
    option.textContent = labels[`image_${name}_${value}`] || value
    el.append(option)
  })
  return el
}

// A <dialog> for choosing an image file and entering its alt text, size and alignment.
// The form fields are not named after page attributes and live outside the page form,
// so they're never submitted with it.
export class ImageDialog {
  constructor(labels, endpoint) {
    this.labels = labels
    this.endpoint = endpoint
    this.build()
  }

  build() {
    const id = `html-editor-image-${++dialogCounter}`
    const l = this.labels

    this.dialog = document.createElement("dialog")
    this.dialog.className = "html-editor-dialog"
    this.dialog.setAttribute("aria-labelledby", `${id}-title`)

    this.form = document.createElement("form")
    this.form.method = "dialog"
    this.form.noValidate = true

    this.title = document.createElement("h2")
    this.title.className = "h5 mb-3"
    this.title.id = `${id}-title`

    this.fileInput = document.createElement("input")
    this.fileInput.type = "file"
    this.fileInput.accept = "image/png,image/jpeg,image/gif,image/webp"
    this.fileInput.className = "form-control"
    this.fileInput.id = `${id}-file`
    this.fileField = field(l.image_file || "Image file", this.fileInput)

    this.preview = document.createElement("img")
    this.preview.className = "html-editor-dialog-preview mb-3"
    this.preview.alt = ""
    this.preview.hidden = true

    this.altInput = document.createElement("input")
    this.altInput.type = "text"
    this.altInput.className = "form-control"
    this.altInput.id = `${id}-alt`
    const altField = field(
      l.image_alt || "Alternative text",
      this.altInput,
      l.image_alt_help,
    )

    this.decorative = document.createElement("input")
    this.decorative.type = "checkbox"
    this.decorative.className = "form-check-input"
    this.decorative.id = `${id}-decorative`
    const decorativeLabel = document.createElement("label")
    decorativeLabel.className = "form-check-label"
    decorativeLabel.htmlFor = this.decorative.id
    decorativeLabel.textContent = l.image_decorative || "Decorative image"
    const decorativeField = document.createElement("div")
    decorativeField.className = "form-check mb-3"
    decorativeField.append(this.decorative, decorativeLabel)
    this.decorative.addEventListener("change", () => {
      this.altInput.disabled = this.decorative.checked
    })

    this.sizeSelect = select(`${id}-size`, "size", IMAGE_SIZES, l)
    this.alignSelect = select(`${id}-align`, "align", IMAGE_ALIGNMENTS, l)
    const layout = document.createElement("div")
    layout.className = "row"
    const sizeCol = field(l.image_size || "Size", this.sizeSelect)
    const alignCol = field(l.image_align || "Position", this.alignSelect)
    sizeCol.classList.add("col")
    alignCol.classList.add("col")
    layout.append(sizeCol, alignCol)

    this.error = document.createElement("div")
    this.error.className = "alert alert-danger"
    this.error.setAttribute("role", "alert")
    this.error.hidden = true

    this.cancelButton = document.createElement("button")
    this.cancelButton.type = "button"
    this.cancelButton.className = "btn btn-link"
    this.cancelButton.textContent = l.cancel || "Cancel"
    this.cancelButton.addEventListener("click", () => this.finish(null))

    this.submitButton = document.createElement("button")
    this.submitButton.type = "submit"
    this.submitButton.className = "btn btn-primary"

    const actions = document.createElement("div")
    actions.className = "d-flex justify-content-end gap-2"
    actions.append(this.cancelButton, this.submitButton)

    this.form.append(
      this.title,
      this.fileField,
      this.preview,
      altField,
      decorativeField,
      layout,
      this.error,
      actions,
    )
    this.dialog.append(this.form)
    document.body.append(this.dialog)

    this.fileInput.addEventListener("change", () => {
      this.file = this.fileInput.files[0]
      this.showPreview(this.file)
    })
    this.form.addEventListener("submit", (event) => {
      event.preventDefault()
      this.submit()
    })
    // Escape key. Cancelling (and finishing) are handled synchronously, rather than in
    // the dialog's "close" event: that event fires asynchronously, and would end the
    // next session if the dialog is reopened right away (e.g. cancel, then paste an image).
    this.dialog.addEventListener("cancel", (event) => {
      event.preventDefault()
      this.finish(null)
    })
  }

  showPreview(file) {
    if (this.objectUrl) URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = file ? URL.createObjectURL(file) : null
    this.preview.src = this.objectUrl || this.preview.src
    this.preview.hidden = !file && !this.attrs?.src
  }

  // Open the dialog. With `attrs` (an existing image), edit it; otherwise insert
  // a new image, optionally starting from a `file` that was dropped or pasted.
  // Resolves with the image attributes to apply, or null if cancelled.
  open({ attrs = null, file = null } = {}) {
    const l = this.labels
    const editing = !!attrs
    this.attrs = attrs
    this.file = file
    this.title.textContent = editing
      ? l.image_edit || "Edit image"
      : l.image_insert || "Insert image"
    this.submitButton.textContent = editing
      ? l.image_save || "Save"
      : l.image_insert_button || "Insert"
    this.fileInput.value = ""
    this.fileField.hidden = editing || !!file
    this.preview.src = attrs?.src || ""
    this.showPreview(file)
    this.altInput.value = attrs?.alt || ""
    this.decorative.checked = !!attrs?.decorative
    this.altInput.disabled = this.decorative.checked
    this.sizeSelect.value = attrs?.size || "medium"
    this.alignSelect.value = attrs?.align || "center"
    this.setError(null)
    this.setBusy(false)
    this.session = (this.session || 0) + 1

    this.dialog.showModal()
    ;(this.fileField.hidden ? this.altInput : this.fileInput).focus()

    return new Promise((resolve) => {
      this.onDone = (result) => {
        this.onDone = null
        resolve(result)
      }
    })
  }

  setError(message) {
    this.error.textContent = message || ""
    this.error.hidden = !message
  }

  setBusy(busy) {
    this.submitButton.disabled = busy
    this.submitButton.setAttribute("aria-busy", busy ? "true" : "false")
  }

  submit() {
    const l = this.labels
    const decorative = this.decorative.checked
    const alt = this.altInput.value.trim()

    if (!this.attrs && !this.file) {
      this.setError(l.image_file_required || "Choose an image to upload.")
      this.fileInput.focus()
      return
    }
    if (!decorative && !alt) {
      this.setError(
        l.image_alt_required ||
          "Enter alternative text, or mark the image as decorative.",
      )
      this.altInput.focus()
      return
    }

    const attrs = {
      alt: decorative ? "" : alt,
      decorative,
      size: this.sizeSelect.value,
      align: this.alignSelect.value,
    }

    if (!this.file) {
      this.finish({ ...attrs, src: this.attrs.src })
      return
    }

    this.setBusy(true)
    this.setError(null)
    // Ignore the upload's result if the dialog was cancelled (or reopened) meanwhile
    const session = this.session
    uploadImage(this.file, this.endpoint)
      .then((src) => session === this.session && this.finish({ ...attrs, src }))
      .catch((error) => {
        if (session !== this.session) return
        console.error(error)
        this.setBusy(false)
        this.setError(
          l.image_upload_failed || "The image could not be uploaded.",
        )
      })
  }

  // Close the dialog and resolve the promise from open() with `result` (null if cancelled)
  finish(result) {
    const done = this.onDone
    this.onDone = null
    this.session += 1
    if (this.objectUrl) URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = null
    if (this.dialog.open) this.dialog.close()
    done?.(result)
  }

  destroy() {
    this.dialog.remove()
  }
}

function imageFiles(fileList) {
  return Array.from(fileList || []).filter((file) =>
    file.type.startsWith("image/"),
  )
}

// editorProps for inserting dropped or pasted image files via the dialog
export function imageDropAndPasteProps(openDialogForFile) {
  return {
    handlePaste(view, event) {
      const [file] = imageFiles(event.clipboardData?.files)
      if (!file) return false
      openDialogForFile(file, view.state.selection.from)
      return true
    },
    handleDrop(view, event, _slice, moved) {
      if (moved) return false
      const [file] = imageFiles(event.dataTransfer?.files)
      if (!file) return false
      event.preventDefault()
      const position = view.posAtCoords({
        left: event.clientX,
        top: event.clientY,
      })
      openDialogForFile(file, position?.pos ?? view.state.selection.from)
      return true
    },
  }
}
