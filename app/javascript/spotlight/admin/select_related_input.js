/*
  Simple helper to select form elements
  when other elements are clicked.
*/
export function selectRelatedInput(elements) {
  if (!elements) return

  const nodes =
    elements instanceof NodeList || Array.isArray(elements)
      ? Array.from(elements)
      : [elements]

  nodes.forEach(function (element) {
    if (!element) return
    const targetSelector = element.getAttribute("data-input-select-target")
    if (!targetSelector) return
    const target = document.querySelector(targetSelector)
    if (!target) return

    const event =
      element.tagName.toLowerCase() === "select" ? "change" : "click"

    element.addEventListener(event, function () {
      if (target.type === "checkbox" || target.type === "radio") {
        target.checked = true
      } else {
        target.focus()
      }
    })
  })
}

export default class {
  connect() {
    selectRelatedInput(document.querySelectorAll("[data-input-select-target]"))
  }
}
