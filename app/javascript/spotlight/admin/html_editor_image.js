// Image support for the WYSIWYG (Tiptap) page editor: an image node with size,
// alignment and alt text, a dialog for inserting/editing images, and uploads
// to the exhibit's attachments endpoint (the same one SirTrevor's image block uses).
import Core from "spotlight/core"
import {
  EditorDialog,
  checkbox,
  field,
  select,
} from "spotlight/admin/html_editor_dialog"

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

// A dialog for choosing an image file and entering its alt text, size and alignment
export class ImageDialog extends EditorDialog {
  constructor(labels, endpoint) {
    super(labels)
    this.endpoint = endpoint
    this.build()
  }

  build() {
    const id = this.id
    const l = this.labels

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

    const decorative = checkbox(
      `${id}-decorative`,
      l.image_decorative || "Decorative image",
    )
    this.decorative = decorative.input
    decorative.wrapper.classList.add("mb-3")
    this.decorative.addEventListener("change", () => {
      this.altInput.disabled = this.decorative.checked
    })

    const optionLabels = (name, values) =>
      values.map((value) => [value, l[`image_${name}_${value}`] || value])
    this.sizeSelect = select(`${id}-size`, optionLabels("size", IMAGE_SIZES))
    this.alignSelect = select(
      `${id}-align`,
      optionLabels("align", IMAGE_ALIGNMENTS),
    )
    const layout = document.createElement("div")
    layout.className = "row"
    const sizeCol = field(l.image_size || "Size", this.sizeSelect)
    const alignCol = field(l.image_align || "Position", this.alignSelect)
    sizeCol.classList.add("col")
    alignCol.classList.add("col")
    layout.append(sizeCol, alignCol)

    this.body.append(
      this.fileField,
      this.preview,
      altField,
      decorative.wrapper,
      layout,
    )

    this.fileInput.addEventListener("change", () => {
      this.file = this.fileInput.files[0]
      this.showPreview(this.file)
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
    this.fileInput.value = ""
    this.fileField.hidden = editing || !!file
    this.preview.src = attrs?.src || ""
    this.showPreview(file)
    this.altInput.value = attrs?.alt || ""
    this.decorative.checked = !!attrs?.decorative
    this.altInput.disabled = this.decorative.checked
    this.sizeSelect.value = attrs?.size || "medium"
    this.alignSelect.value = attrs?.align || "center"

    return this.show({
      title: editing
        ? l.image_edit || "Edit image"
        : l.image_insert || "Insert image",
      submitLabel: editing
        ? l.image_save || "Save"
        : l.image_insert_button || "Insert",
      focus: this.fileField.hidden ? this.altInput : this.fileInput,
    })
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
      .then((src) => this.isCurrent(session) && this.finish({ ...attrs, src }))
      .catch((error) => {
        if (!this.isCurrent(session)) return
        console.error(error)
        this.setBusy(false)
        this.setError(
          l.image_upload_failed || "The image could not be uploaded.",
        )
      })
  }

  cleanup() {
    if (this.objectUrl) URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = null
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
