export default class {
  connect() {
    const clearButtons = document.querySelectorAll(".btn-reset")

    clearButtons.forEach(clearBtn => {
      const input =
        clearBtn.previousElementSibling &&
        clearBtn.previousElementSibling.id === "browse_q"
          ? clearBtn.previousElementSibling
          : null

      if (!input) return

      const btnCheck = () => {
        if (input.value !== "") {
          clearBtn.style.display = "block"
        } else {
          clearBtn.style.display = "none"
        }
      }

      btnCheck()

      input.addEventListener("keyup", btnCheck)

      clearBtn.addEventListener("click", event => {
        event.preventDefault()
        input.value = ""
        btnCheck()
      })
    })
  }
}
