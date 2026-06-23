export default class {
  connect() {
    document.querySelectorAll("[data-action='add-another']").forEach(button => {
      button.addEventListener("click", event => {
        event.preventDefault()

        const templateId = button.dataset.templateId
        if (!templateId) return

        const template = document.getElementById(templateId)
        if (!template) return

        const clone = document.importNode(template.content, true)

        const formGroup = button.closest(".form-group")
        if (!formGroup) return

        const firstNamedElement = clone.querySelector("[name]")
        if (!firstNamedElement) return

        const nameAttr = firstNamedElement.getAttribute("name")
        const existingElements = formGroup.querySelectorAll(
          `[name="${nameAttr}"]`
        )
        const count = existingElements.length + 1

        clone.querySelectorAll("[id]").forEach(el => {
          const currentId = el.getAttribute("id")
          el.setAttribute("id", `${currentId}_${count}`)
        })

        clone.querySelectorAll("[for]").forEach(el => {
          const currentFor = el.getAttribute("for")
          el.setAttribute("for", `${currentFor}_${count}`)
        })

        button.parentNode.insertBefore(clone, button)
      })
    })
  }
}
