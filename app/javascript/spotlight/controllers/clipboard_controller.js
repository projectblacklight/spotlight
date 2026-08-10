import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["text"]

  async copy() {
    try {
      await navigator.clipboard.writeText(this.textTarget.innerText)
    } catch (err) {
      console.error("Clipboard controller failed to copy with error:", err)
    }
  }
}
