import { URLify } from "parameterize"

export default class {
  connect() {
    // auto-fill the exhibit slug on the new exhibit form
    const newExhibit = document.getElementById("new_exhibit")
    if (newExhibit) {
      const exhibitTitle = document.getElementById("exhibit_title")
      const exhibitSlug = document.getElementById("exhibit_slug")

      if (exhibitTitle && exhibitSlug) {
        const updatePlaceholder = () => {
          const val = exhibitTitle.value || ""
          exhibitSlug.placeholder = URLify(val, val.length)
        }

        exhibitTitle.addEventListener("change", updatePlaceholder)
        exhibitTitle.addEventListener("keyup", updatePlaceholder)

        exhibitSlug.addEventListener("focus", () => {
          if (exhibitSlug.value === "") {
            exhibitSlug.value = exhibitSlug.placeholder || ""
          }
        })
      }
    }

    const anotherEmail = document.getElementById("another-email")
    if (anotherEmail) {
      anotherEmail.addEventListener("click", e => {
        e.preventDefault()

        const container = anotherEmail.closest(".form-group")
        if (!container) return

        const contacts = container.querySelectorAll(".contact")
        if (contacts.length === 0) return

        const firstContact = contacts[0]
        const inputContainer = firstContact.cloneNode(true)

        // wipe out any values from the inputs
        const inputs = inputContainer.querySelectorAll("input")
        inputs.forEach(input => {
          input.value = ""
          const originalId = input.getAttribute("id")
          if (originalId) {
            input.setAttribute(
              "id",
              originalId.replace("0", contacts.length.toString())
            )
          }
          const originalName = input.getAttribute("name")
          if (originalName) {
            input.setAttribute(
              "name",
              originalName.replace("0", contacts.length.toString())
            )
          }
          const originalAriaLabel = input.getAttribute("aria-label")
          if (originalAriaLabel) {
            input.setAttribute(
              "aria-label",
              originalAriaLabel.replace("1", (contacts.length + 1).toString())
            )
          }
        })

        inputContainer
          .querySelectorAll(".contact-email-delete-wrapper")
          .forEach(el => el.remove())
        inputContainer
          .querySelectorAll(".confirmation-status")
          .forEach(el => el.remove())

        // bootstrap does not render input-groups with only one value in them correctly.
        const onlyChildInputs = inputContainer.querySelectorAll(
          ".input-group input:only-child"
        )
        onlyChildInputs.forEach(input => {
          const group = input.closest(".input-group")
          if (group) {
            group.classList.remove("input-group")
          }
        })

        contacts[contacts.length - 1].after(inputContainer)
      })
    }

    if (document.getElementById("another-email")) {
      document.addEventListener(
        "turbo:submit-end",
        this.contactToDeleteNotFoundHandler
      )
    }

    // Put focus in saved search title input when Save this search modal is shown
    const saveModal = document.getElementById("save-modal")
    if (saveModal) {
      saveModal.addEventListener("shown.bs.modal", () => {
        const searchTitle = document.getElementById("search_title")
        if (searchTitle) {
          searchTitle.focus()
        }
      })
    }
  }

  contactToDeleteNotFoundHandler(e) {
    const contact =
      e.detail.formSubmission?.delegate?.element?.querySelector(".contact")
    if (contact && e.detail?.fetchResponse?.response?.status === 404) {
      const error = contact.querySelector(".contact-email-delete-error")
      if (error) {
        error.style.display = "block"
        const errorMsg = error.querySelector(".error-msg")
        if (errorMsg) {
          errorMsg.textContent = "Not Found"
        }
      }
    }
  }
}
