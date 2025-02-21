import { Controller } from '@hotwired/stimulus'

export default class extends Controller {

  static targets = [
    'addNewTagWrapper',
    'dropdownContent',
    'initialTags',
    'newTag',
    'searchResultTags',
    'selectedTags',
    'tagControlWrapper',
    'tagSearch',
    'tagsField',
    'tagSearchDropdown',
    'tagSearchInputWrapper'
  ]

  static values = {
    tags: Array,
    translations: Object
  }

  tagDropdown (event) {
    this.dropdownContentTarget.classList.toggle('d-none')
  }

  clickOutside (event) {
    const isShown = !this.dropdownContentTarget.classList.contains('d-none')
    const inSelected = event.target.classList.contains('pill-close')
    const inContainer = this.tagControlWrapperTarget.contains(event.target)
    if (!inContainer && !inSelected && isShown) {
      this.tagDropdown(event)
    }
  }

  handleKeydown (event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      const hidden = this.dropdownContentTarget.classList.contains('d-none')
      if (hidden) return;

      const tagElementToAdd = this.dropdownContentTarget.querySelector('.active')?.firstElementChild
      if (tagElementToAdd) tagElementToAdd.click()
    }

    if (event.key === ',') {
      event.preventDefault()
      if (this.tagSearchTarget.value.length === 0) return

      if (!this.addNewTagWrapperTarget.classList.contains('d-none')) {
        this.addNewTagWrapperTarget.click()
        this.tagSearchTarget.focus()
        return
      }

      const exactMatch = this.dropdownContentTarget.querySelector('.active')?.firstElementChild
      if (exactMatch?.checked === false) {
        exactMatch.click()
        this.resetSearch()
      }
      this.tagSearchTarget.focus()
    }
  }

  addNewTag (event) {
    if (this.addNewTagWrapperTarget.classList.contains('d-none') || this.newTagTarget.dataset.tag.length === 0) {
      return
    }

    this.tagsValue = this.tagsValue.concat([this.newTagTarget.dataset.tag])
    this.resetSearch()
  }

  resetSearch() {
    this.tagSearchTarget.value = ''
    this.newTagTarget.innerHTML = ''
    this.newTagTarget.dataset.tag = ''
    this.newTagTarget.disabled = true
    this.addNewTagWrapperTarget.classList.add('d-none')
    this.searchResultTagsTargets.forEach(target => this.showElement(target.parentElement))
  }

  tagUpdate (event) {
    const target = event.target ? event.target : event
    if (target.checked) {
      this.tagsValue = this.tagsValue.concat([target.dataset.tag])
    } else {
      this.tagsValue = this.tagsValue.filter(tag => tag !== target.dataset.tag)
    }
  }

  updateSearchResultsPlaceholder(event) {
    const placeholderElement = this.dropdownContentTarget.querySelector('.no-results')
    if (!placeholderElement) return

    const hasVisibleTags = this.dropdownContentTarget.querySelector('label:not(.d-none):not(.no-results)')
    placeholderElement.classList.toggle('d-none', hasVisibleTags)
  }

  tagCreate(event) {
    event.preventDefault()
    const newTagCheckbox = document.createElement('label')
    newTagCheckbox.innerHTML = `<input type="checkbox" checked data-action="click->${this.identifier}#tagUpdate" data-tag-selector-target="searchResultTags" data-tag="${this.newTagTarget.dataset.tag}"> ${this.newTagTarget.dataset.tag}`
    const existingTags = Array.from(this.dropdownContentTarget.querySelectorAll('label:not(#add-new-tag-wrapper)'))
    const insertPosition = existingTags.findIndex(tag => tag.textContent.trim().localeCompare(this.newTagTarget.dataset.tag) > 0)
    if (insertPosition === -1) {
      this.addNewTagWrapperTarget.insertAdjacentElement('beforebegin', newTagCheckbox)
    } else {
      existingTags[insertPosition].insertAdjacentElement('beforebegin', newTagCheckbox)
    }

    this.tagsValue = this.tagsValue.concat([this.newTagTarget.dataset.tag])
    this.tagSearchTarget.value = ''
    this.tagSearchTarget.dispatchEvent(new Event('input'))
  }


  tagsValueChanged() {
    const isEmpty = this.tagsValue.length === 0

    this.selectedTagsTarget.classList.toggle('d-none', isEmpty)
    this.tagSearchInputWrapperTarget.classList.toggle('rounded', isEmpty)
    this.tagSearchInputWrapperTarget.classList.toggle('rounded-bottom', !isEmpty)

    if (!isEmpty) {
      this.selectedTagsTarget.innerHTML = `<ul class="list-unstyled border rounded-top mb-0 p-1 px-2">${this.renderTagPills()}</ul>`
    }

    const newValue = this.tagsValue.join(', ')
    if (this.tagsFieldTarget.value !== newValue) {
      this.tagsFieldTarget.value = newValue
    }
  }

  normalizeTag (tag) {
    const normalizeRegex = /[^\w\s]/gi
    return tag.replace(normalizeRegex, '').toLowerCase().trim()
  }

  showElement (element) {
    element.classList.add('d-block')
    element.classList.remove('d-none')
  }

  hideElement (element) {
    element.classList.remove('d-block')
    element.classList.add('d-none')
  }

  search(event) {
    const searchTerm = this.normalizeTag(event.target.value)
    this.dropdownContentTarget.classList.remove('d-none')

    const exactMatch = this.searchResultTagsTargets.some(target => {
      const compareTerm = this.normalizeTag(target.dataset.tag)
      const isMatch = compareTerm.includes(searchTerm)
      target.parentElement.classList.remove('active')
      this[isMatch ? 'showElement' : 'hideElement'](target.parentElement)
      return compareTerm === searchTerm
    })

    this[searchTerm.length > 0 && !exactMatch ? 'showElement' : 'hideElement'](this.addNewTagWrapperTarget)
    this.addNewTagWrapperTarget.classList.remove('active')
    this.dropdownContentTarget.querySelector('label:not(.d-none)')?.classList.add('active')
  }

  updateTagToAdd (event) {
    const tagAlreadyAdded = this.tagsValue.some(tag =>
      this.normalizeTag(tag) === this.normalizeTag(event.target.value)
    )
    this.newTagTarget.dataset.tag = event.target.value.trim()
    this.newTagTarget.nextSibling.textContent = ` ${this.translationsValue.add_new_tag}: ${event.target.value}`
    this.newTagTarget.disabled = !this.newTagTarget.dataset.tag.length || tagAlreadyAdded
  }

  deselect (event) {
    event.preventDefault()

    const clickedTag = event.target.closest('button').dataset.tag
    const target = this.searchResultTagsTargets.find((tag) => tag.dataset.tag === clickedTag)
    target ? target.click() : this.tagsValue = this.tagsValue.filter(tag => tag !== clickedTag)
  }

  renderTagPills () {
    return this.tagsValue.map((tag) => {
      return `
        <li class="d-inline-flex gap-2 align-items-center my-2">
          <span class="bg-light badge rounded-pill border selected-item d-inline-flex align-items-center text-dark">
            <span class="selected-item-label d-inline-flex">${tag}</span>
            <button
              type="button"
              data-action="${this.identifier}#deselect"
              data-tag="${tag}"
              class="btn-close close ms-1"
              aria-label="${this.translationsValue.remove} ${tag}"
            ></button>
          </span>
        </li>
      `
    }).join('')
  }
}
