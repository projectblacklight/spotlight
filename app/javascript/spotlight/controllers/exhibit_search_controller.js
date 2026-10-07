import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exhibit-search"
// Fetches the exhibits index for the current query and swaps in each tab pane,
// so the list filters as the user types without moving focus out of the field.
export default class extends Controller {
  static targets = ["form", "input", "pane", "status"]

  disconnect() {
    clearTimeout(this.timeout)
    this.abortController?.abort()
  }

  queue() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.search(), 300)
  }

  submit(event) {
    event.preventDefault()
    clearTimeout(this.timeout)
    this.search()
  }

  clear(event) {
    if (this.inputTarget.value === "") return

    event.preventDefault()
    this.inputTarget.value = ""
    clearTimeout(this.timeout)
    this.search()
  }

  async search() {
    const url = this.url()

    this.abortController?.abort()
    this.abortController = new AbortController()

    try {
      const response = await fetch(url, {
        headers: { Accept: "text/html" },
        signal: this.abortController.signal,
      })
      if (!response.ok) throw new Error(response.statusText)

      this.update(
        new DOMParser().parseFromString(await response.text(), "text/html"),
      )
      history.replaceState(history.state, "", url)
    } catch (error) {
      if (error.name === "AbortError") return

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

    const activePane = this.paneTargets.find((pane) =>
      pane.classList.contains("active"),
    )
    this.statusTarget.textContent =
      activePane?.dataset.exhibitSearchStatus ?? ""
  }

  url() {
    const params = new URLSearchParams(new FormData(this.formTarget))
    if (!params.get("q").trim()) params.delete("q")

    const url = new URL(this.formTarget.action)
    url.search = params.toString()
    return url
  }
}
