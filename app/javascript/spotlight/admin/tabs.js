import bootstrap from "bootstrap"

export default class {
  connect() {
    if (document.querySelector("[role=tabpanel]") && window.location.hash) {
      const targetId = window.location.hash.substring(1)
      const targetElement = document.getElementById(targetId)
      if (!targetElement) return

      const tabpanel = targetElement.closest("[role=tabpanel]")
      if (!tabpanel) return

      const tabElement = document.querySelector(
        `a[role=tab][href="#${tabpanel.id}"]`
      )
      if (!tabElement) return

      bootstrap.Tab.getOrCreateInstance(tabElement).show()
    }
  }
}
