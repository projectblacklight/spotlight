import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="clipboard"
export default class extends Controller {
  static targets = ["text"]

  async copy(event) {
    try {
      await navigator.clipboard.write([new ClipboardItem({ "text/html": this.textTarget.innerHTML, "text/plain": this.textTarget.innerText })])
    } catch (err) {
      console.error('Clipboard controller failed to copy with error:', err)
    }
  }
}
