// Shared behavior for the WYSIWYG editor's modal dialogs (images, embedded items):
// a native <dialog> with a form, an error message, and Cancel/submit buttons.
//
// open() returns a promise for the dialog's result (null if cancelled). Cancelling and
// finishing are handled synchronously, rather than in the dialog's "close" event: that
// event fires asynchronously, and would end the next session if the dialog is reopened
// right away (e.g. cancel, then paste an image).

let dialogCounter = 0

export function nextDialogId(prefix) {
  return `${prefix}-${++dialogCounter}`
}

export function field(labelText, control, help) {
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

export function checkbox(id, labelText) {
  const input = document.createElement("input")
  input.type = "checkbox"
  input.className = "form-check-input"
  input.id = id
  const label = document.createElement("label")
  label.className = "form-check-label"
  label.htmlFor = id
  label.textContent = labelText
  const wrapper = document.createElement("div")
  wrapper.className = "form-check"
  wrapper.append(input, label)
  return { input, wrapper }
}

// options: [[value, label], ...]
export function select(id, options) {
  const el = document.createElement("select")
  el.className = "form-select"
  el.id = id
  options.forEach(([value, label]) => {
    const option = document.createElement("option")
    option.value = value
    option.textContent = label
    el.append(option)
  })
  return el
}

export class EditorDialog {
  constructor(labels, { className = "" } = {}) {
    this.labels = labels
    this.session = 0
    this.id = nextDialogId("html-editor-dialog")

    this.dialog = document.createElement("dialog")
    this.dialog.className = `html-editor-dialog ${className}`.trim()
    this.dialog.setAttribute("aria-labelledby", `${this.id}-title`)

    // The fields live outside the page form, so they're never submitted with it
    this.form = document.createElement("form")
    this.form.method = "dialog"
    this.form.noValidate = true

    this.title = document.createElement("h2")
    this.title.className = "h5 mb-3"
    this.title.id = `${this.id}-title`

    this.body = document.createElement("div")

    this.error = document.createElement("div")
    this.error.className = "alert alert-danger"
    this.error.setAttribute("role", "alert")
    this.error.hidden = true

    this.cancelButton = document.createElement("button")
    this.cancelButton.type = "button"
    this.cancelButton.className = "btn btn-link"
    this.cancelButton.textContent = labels.cancel || "Cancel"
    this.cancelButton.addEventListener("click", () => this.finish(null))

    this.submitButton = document.createElement("button")
    this.submitButton.type = "submit"
    this.submitButton.className = "btn btn-primary"

    const actions = document.createElement("div")
    actions.className = "d-flex justify-content-end gap-2"
    actions.append(this.cancelButton, this.submitButton)

    this.form.append(this.title, this.body, this.error, actions)
    this.dialog.append(this.form)
    document.body.append(this.dialog)

    this.form.addEventListener("submit", (event) => {
      event.preventDefault()
      this.submit()
    })
    // Escape key
    this.dialog.addEventListener("cancel", (event) => {
      event.preventDefault()
      this.finish(null)
    })
  }

  // Show the dialog; resolves with the result passed to finish() (null if cancelled)
  show({ title, submitLabel, focus }) {
    this.title.textContent = title
    this.submitButton.textContent = submitLabel
    this.setError(null)
    this.setBusy(false)
    this.session += 1

    this.dialog.showModal()
    focus?.focus()

    return new Promise((resolve) => {
      this.onDone = resolve
    })
  }

  // Is `session` (captured before an async step) still the dialog's current session?
  isCurrent(session) {
    return session === this.session && this.dialog.open
  }

  setError(message) {
    this.error.textContent = message || ""
    this.error.hidden = !message
  }

  setBusy(busy) {
    this.submitButton.disabled = busy
    this.submitButton.setAttribute("aria-busy", busy ? "true" : "false")
  }

  // Subclasses validate their fields and call finish(result)
  submit() {}

  // Called when the dialog is finished or cancelled, before it closes
  cleanup() {}

  // Close the dialog and resolve the promise from show() with `result`
  finish(result) {
    const done = this.onDone
    this.onDone = null
    this.session += 1
    this.cleanup()
    if (this.dialog.open) this.dialog.close()
    done?.(result)
  }

  destroy() {
    this.dialog.remove()
  }
}
