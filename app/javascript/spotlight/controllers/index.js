import TagSelectorController from 'spotlight/controllers/tag_selector_controller'

export default class {
  connect() {
    if (typeof Stimulus === "undefined") return
    Stimulus.register('tag-selector', TagSelectorController)
  }
}
