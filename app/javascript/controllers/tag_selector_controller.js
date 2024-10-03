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
    'textExtractionDropdown'
  ]

  static values = { 
    tags: Array,
    closeButtonHtml: String,
    translations: Object
  }

  tagDropdown (event) {
    const ishidden = this.dropdownContentTarget.classList.contains('d-none')
    this.dropdownContentTarget.classList.toggle('d-none')
    this.textExtractionDropdownTarget.querySelector('#caret').innerHTML = `<i class="bi bi-caret-${ishidden ? 'up' : 'down'}">`
  }

  clickOutside (event) {
    const isshown = !this.dropdownContentTarget.classList.contains('d-none')
    const inselected = event.target.classList.contains('pill-close')
    const incontainer = this.tagControlWrapperTarget.contains(event.target)

    if (!incontainer && !inselected && isshown) {
      this.tagDropdown(event)
    }
  }

  handleKeydown (event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      const tagElementToAdd = this.dropdownContentTarget.querySelector('.active').firstElementChild
      if (tagElementToAdd) tagElementToAdd.click()
    }

    if (event.key === ',') {
      event.preventDefault()
      this.addNewTagWrapperTarget.click()
      this.tagSearchTarget.focus()
    }
  }

  addNewTag (event) {
    if (this.addNewTagWrapperTarget.classList.contains('d-none') || this.newTagTarget.dataset.tag.length === 0) {
      return
    }

    this.tagsValue = this.tagsValue.concat([this.newTagTarget.dataset.tag])
    this.resetSearch(event)
  }

  resetSearch(event) {
    this.tagSearchTarget.value = ''
    this.newTagTarget.innerHTML = ''
    this.newTagTarget.dataset.tag = '' 
    this.addNewTagWrapperTarget.classList.remove('d-block')
    this.addNewTagWrapperTarget.classList.add('d-none')

    this.searchResultTagsTargets.forEach(target => {
      target.parentElement.classList.add('d-block')
      target.parentElement.classList.remove('d-none')
    })
  }

  tagUpdate (event) {
    const target = event.target ? event.target : event
    if (target.checked) {
      this.tagsValue = this.tagsValue.concat([target.dataset.tag])
    } else {
      this.tagsValue = this.tagsValue.filter(tag => tag !== target.dataset.tag)
    }
  }

  tagCreate(event) {
    event.preventDefault()
    const newTagCheckbox = document.createElement('label')
    newTagCheckbox.classList.add('d-block')
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

  tagsValueChanged () {
    if (this.tagsValue.length === 0) {
      this.selectedTagsTarget.classList.add('d-none')
    } else {
      this.selectedTagsTarget.classList.remove('d-none')
      this.selectedTagsTarget.innerHTML = `<div>${this.translationsValue.selected_tags}</div>
                                                <ul class="list-unstyled border rounded mb-3 p-1">${this.renderTagPills()}</ul>`
    }

    // The backend expects the comma with the space. If we're not careful here, observedFormsStatusHasChanged
    // will return true and warn the user that the form has changed, even when it really hasn't.
    const newValue = this.tagsValue.join(', ')
    if (this.tagsFieldTarget.value !== newValue) {
      this.tagsFieldTarget.value = newValue
    }
  }

  search (event) {
    const normalizeRegex = /[^\w\s]/gi
    const searchTerm = event.target.value.replace(normalizeRegex, '').toLowerCase().trim()
    let exactMatch = false
    this.dropdownContentTarget.classList.remove('d-none')

    this.searchResultTagsTargets.forEach(target => {
      target.parentElement.classList.remove('active')
      const compareTerm = target.dataset.tag.replace(normalizeRegex, '').toLowerCase().trim()
      if (compareTerm.includes(searchTerm)) {
        target.parentElement.classList.add('d-block')
        target.parentElement.classList.remove('d-none')
        if (compareTerm === searchTerm) exactMatch = true
      } else {
        target.parentElement.classList.add('d-none')
        target.parentElement.classList.remove('d-block')
      }
    })

    if (searchTerm.length > 0 && !exactMatch) {
      this.addNewTagWrapperTarget.classList.remove('d-none')
      this.addNewTagWrapperTarget.classList.add('d-block')
    } else {
      this.addNewTagWrapperTarget.classList.add('d-none')
      this.addNewTagWrapperTarget.classList.remove('d-block')
    }
    this.addNewTagWrapperTarget.classList.remove('active')

    const firstVisibleTag = this.dropdownContentTarget.querySelector('label.d-block')
    if (firstVisibleTag) {
      firstVisibleTag.classList.add('active')
    }
  }

  updateTagToAdd (event) {
    this.newTagTarget.dataset.tag = event.target.value.trim()
    this.newTagTarget.nextSibling.textContent = ` ${this.translationsValue.add_new_tag}: ${event.target.value}`
  }

  deselect (event) {
    event.preventDefault()

    const target = this.searchResultTagsTargets.find((tag) => tag.dataset.tag === event.target.dataset.tag)
    if (target) {
      target.checked = false
      this.tagUpdate(target)
    } else {
      this.tagsValue = this.tagsValue.filter(tag => tag !== event.target.dataset.tag)
    }
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
              class="btn-close close ms-1 ml-1"
              aria-label="${this.translationsValue.remove} ${tag}"
            >${this.closeButtonHtmlValue}</button>
          </span>
        </li>
      `
    }).join('')
  }
}
