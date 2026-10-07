import { Controller } from "@hotwired/stimulus"

// Live-filters the exhibit cards on the exhibits index page. The form works
// as a plain GET without JavaScript; this fetches the same page and swaps the
// results in place, leaving focus in the search field.
export default class extends Controller {
  static targets = ["form", "input", "status"]

  static values = {
    delay: { type: Number, default: 350 },
  }

  connect() {
    this.tabShown = () => this.announce()
    document.addEventListener("shown.bs.tab", this.tabShown)
  }

  disconnect() {
    clearTimeout(this.timeout)
    this.abortController?.abort()
    document.removeEventListener("shown.bs.tab", this.tabShown)
  }

  queue() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.search(), this.delayValue)
  }

  submit(event) {
    event.preventDefault()
    clearTimeout(this.timeout)
    this.search()
  }

  // The browser's own clear button fires an input event, which queues a
  // search. Escape is handled here so it behaves the same in every browser.
  escape(event) {
    if (this.inputTarget.value === "") return

    event.preventDefault()
    this.inputTarget.value = ""
    clearTimeout(this.timeout)
    this.search()
  }

  async search() {
    const url = this.requestUrl()
    const results = document.getElementById("exhibit-search-results")

    this.abortController?.abort()
    this.abortController = new AbortController()
    results?.setAttribute("aria-busy", "true")

    try {
      const response = await fetch(url, {
        headers: { Accept: "text/html" },
        signal: this.abortController.signal,
      })
      if (!response.ok) throw new Error(response.statusText)

      const html = await response.text()
      this.update(new DOMParser().parseFromString(html, "text/html"))
      history.replaceState(history.state, "", this.displayUrl(url))
      results?.removeAttribute("aria-busy")
    } catch (error) {
      if (error.name === "AbortError") return

      window.location.assign(this.displayUrl(url))
    }
  }

  update(doc) {
    doc.querySelectorAll("[data-exhibit-search-swap][id]").forEach((source) => {
      const target = document.getElementById(source.id)
      if (!target) return

      target.innerHTML = source.innerHTML
      target.dataset.exhibitSearchStatus =
        source.dataset.exhibitSearchStatus ?? ""
    })

    this.announce()
  }

  // Show (and announce) the message for the selected tab only.
  announce() {
    const pane = document.querySelector("#exhibit-search-results > .active")
    const status = pane?.dataset.exhibitSearchStatus ?? ""
    // Only touch the live region when the message changes, so screen readers
    // aren't interrupted by a repeat of the same count.
    if (this.statusTarget.textContent !== status) {
      this.statusTarget.textContent = status
    }
  }

  // The URL to fetch. An empty q is kept so the server can report that all
  // exhibits are shown again.
  requestUrl() {
    const url = new URL(this.formTarget.action, window.location.href)
    url.search = new URLSearchParams(new FormData(this.formTarget)).toString()
    return url
  }

  // The URL to show in the address bar, without an empty q.
  displayUrl(url) {
    const display = new URL(url)
    if (!display.searchParams.get("q")?.trim()) {
      display.searchParams.delete("q")
    }
    return display
  }
}
