import ClipboardController from "spotlight/controllers/clipboard_controller"
import ExhibitSearchController from "spotlight/controllers/exhibit_search_controller"
import TagSelectorController from "spotlight/controllers/tag_selector_controller"

export default class {
  connect() {
    if (typeof Stimulus === "undefined") return
    Stimulus.register("clipboard", ClipboardController)
    Stimulus.register("exhibit-search", ExhibitSearchController)
    Stimulus.register("tag-selector", TagSelectorController)
  }
}
