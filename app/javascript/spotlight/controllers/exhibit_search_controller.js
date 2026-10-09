import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exhibit-search"
// Fetches the exhibits index for the current query and swaps in each tab pane,
// so the list filters as the user types without moving focus out of the field.
export default class extends Controller {
  static targets = ["input", "pane", "status"]
  static values = {
    debounceDelay: { type: Number, default: 300 },
  }

  disconnect() {
    clearTimeout(this.timeout)
    this.abortController?.abort()
  }

  debounce() {
    this.searchLater(this.inputTarget.value)
  }

  query({ detail: { q } }) {
    this.searchLater(q)
  }

  searchLater(query) {
    clearTimeout(this.timeout)
    this.abortController?.abort()
    this.timeout = setTimeout(() => this.search(query), this.debounceDelayValue)
  }

  submit(event) {
    event.preventDefault()
    this.search(this.inputTarget.value)
  }

  clear(event) {
    if (this.inputTarget.value === "") return

    event.preventDefault()
    this.inputTarget.value = ""
    this.search("")
  }

  async search(query) {
    clearTimeout(this.timeout)
    const url = this.url(query)

    this.abortController?.abort()
    const abortController = new AbortController()
    this.abortController = abortController

    try {
      const response = await fetch(url, {
        headers: { Accept: "text/html" },
        signal: abortController.signal,
      })
      if (!response.ok) throw new Error(response.statusText)

      const html = await response.text()
      if (abortController.signal.aborted) return

      this.update(new DOMParser().parseFromString(html, "text/html"))
      history.replaceState(history.state, "", url)
    } catch (error) {
      if (abortController.signal.aborted || error.name === "AbortError") return

      window.location.assign(url)
    }
  }

  update(doc) {
    this.paneTargets.forEach((pane) => {
      const source = doc.getElementById(pane.id)
      if (!source) return

      pane.innerHTML = source.innerHTML
      pane.dataset.exhibitSearchStatus = source.dataset.exhibitSearchStatus
    })

    this.announce()
  }

  announce() {
    const activePane = this.paneTargets.find((pane) =>
      pane.classList.contains("active"),
    )
    this.statusTarget.textContent =
      activePane?.dataset.exhibitSearchStatus ?? ""
  }

  // Start from the current URL so the selected tag stays, but a new query starts at the first page.
  url(query) {
    const url = new URL(window.location.href)
    url.searchParams.delete("page")
    if (query.trim()) {
      url.searchParams.set("q", query)
    } else {
      url.searchParams.delete("q")
    }
    return url
  }
}
