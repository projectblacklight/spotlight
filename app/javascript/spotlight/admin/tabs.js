import * as bootstrap from "bootstrap"

// Bootstrap's ESM build exports Tab by name; CDN-converted UMD builds (e.g. ga.jspm.io) only have a default export
const Tab = bootstrap.Tab ?? bootstrap.default?.Tab

export default class {
  connect() {
    if (document.querySelector("[role=tabpanel]") && window.location.hash) {
      const targetId = window.location.hash.substring(1)
      const targetElement = document.getElementById(targetId)
      if (!targetElement) return

      const tabpanel = targetElement.closest("[role=tabpanel]")
      if (!tabpanel) return

      const tabElement = document.querySelector(
        `a[role=tab][href="#${tabpanel.id}"]`,
      )
      if (!tabElement) return

      Tab.getOrCreateInstance(tabElement).show()
    }
  }
}
