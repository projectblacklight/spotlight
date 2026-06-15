export default class {
  connect() {
    document
      .querySelectorAll(".edit_exhibit, .admin-users")
      .forEach(container => {
        const edit_user = event => {
          event.preventDefault()
          const button = event.currentTarget
          const row = button.closest("tr")
          row.style.display = "none"

          const id = button.getAttribute("data-target")
          const edit_view = container.querySelector(`[data-edit-for='${id}']`)
          edit_view.style.display = ""

          // Cache original values in case editing is canceled
          edit_view
            .querySelectorAll('input[type="text"], select')
            .forEach(input => {
              input.dataset.orig = input.value
            })
        }

        const cancel_edit = event => {
          event.preventDefault()
          const button = event.currentTarget
          const edit_view = button.closest("tr[data-edit-for]")
          const id = edit_view.getAttribute("data-edit-for")

          // Hide all rows with this id
          container.querySelectorAll(`[data-edit-for='${id}']`).forEach(row => {
            row.style.display = "none"
          })

          clear_errors(edit_view)
          rollback_changes(edit_view)

          const show_view = container.querySelector(`[data-show-for='${id}']`)
          if (show_view) {
            show_view.style.display = ""
          }
        }

        const clear_errors = element => {
          element.querySelectorAll(".has-error").forEach(errorElement => {
            errorElement.classList.remove("has-error")
          })
          element.querySelectorAll(".form-text").forEach(formText => {
            formText.remove()
          })
        }

        const rollback_changes = element => {
          element
            .querySelectorAll('input[type="text"], select')
            .forEach(input => {
              if (input.dataset.orig !== undefined) {
                input.value = input.dataset.orig
                input.dispatchEvent(new Event("change", { bubbles: true }))
              }
            })
        }

        const destroy_user = event => {
          const button = event.currentTarget
          const id = button.getAttribute("data-target")
          const destroyInput = container.querySelector(
            `[data-destroy-for='${id}']`
          )
          if (destroyInput) {
            destroyInput.value = "1"
          }
        }

        const new_user = event => {
          event.preventDefault()
          // Show ALL rows with data-edit-for='new'
          container
            .querySelectorAll(`[data-edit-for='new']`)
            .forEach(edit_view => {
              edit_view.style.display = ""

              // Cache original values in case editing is canceled
              edit_view
                .querySelectorAll('input[type="text"], select')
                .forEach(input => {
                  input.dataset.orig = input.value
                })
            })
        }

        const open_errors = () => {
          // Find all rows with errors within this container
          const allErrorElements = container.querySelectorAll(".has-error")
          const rowsToShow = new Set()

          allErrorElements.forEach(errorElement => {
            const edit_row = errorElement.closest("[data-edit-for]")
            if (edit_row) {
              // Show all rows with the same data-edit-for value
              const id = edit_row.getAttribute("data-edit-for")
              container
                .querySelectorAll(`[data-edit-for='${id}']`)
                .forEach(row => {
                  rowsToShow.add(row)
                })
            }
          })

          rowsToShow.forEach(row => {
            row.style.display = ""
          })
        }

        // First, hide all edit views
        container.querySelectorAll("[data-edit-for]").forEach(element => {
          element.style.display = "none"
        })

        // Then show any with errors
        open_errors()

        // Attach event listeners
        container
          .querySelectorAll("[data-behavior='edit-user']")
          .forEach(button => {
            button.addEventListener("click", edit_user)
          })

        container
          .querySelectorAll("[data-behavior='cancel-edit']")
          .forEach(button => {
            button.addEventListener("click", cancel_edit)
          })

        container
          .querySelectorAll("[data-behavior='destroy-user']")
          .forEach(button => {
            button.addEventListener("click", destroy_user)
          })

        container
          .querySelectorAll("[data-behavior='new-user']")
          .forEach(button => {
            button.addEventListener("click", new_user)
          })
      })
  }
}
