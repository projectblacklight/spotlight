import { addImageSelector } from "spotlight/admin/add_image_selector"

const docStore = new Map()

function highlight(value, query) {
  if (query.trim() === "") return value
  const queryValue = query.trim()
  return queryValue
    ? value.replace(new RegExp(queryValue, "gi"), "<strong>$&</strong>")
    : value
}

function templateFunc(obj, query) {
  const thumbnail = obj.thumbnail
    ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>`
    : ""
  const privateClass = obj.private ? " blacklight-private" : ""
  const title = highlight(obj.title, query)
  const description = obj.description
    ? `<small>&nbsp;&nbsp;${highlight(obj.description, query)}</small>`
    : ""
  return `<div class="autocomplete-item${privateClass}">${thumbnail}
            <span class="autocomplete-title">${title}</span><br/>${description}
          </div>`
}

function autoCompleteElementTemplate(obj, query) {
  return `<li role="option" data-autocomplete-value="${obj.id}">${templateFunc(obj, query)}</li>`
}

function getAutoCompleteElementDataMap(autoCompleteElement) {
  if (!docStore.has(autoCompleteElement.id)) {
    docStore.set(autoCompleteElement.id, new Map())
  }
  return docStore.get(autoCompleteElement.id)
}

async function fetchResult(url) {
  const result = await fetchAutocompleteJSON(url)
  const docs = result.docs || []
  const query = this.querySelector("input").value || ""
  const autoCompleteElementDataMap = getAutoCompleteElementDataMap(this)
  return docs
    .map(doc => {
      autoCompleteElementDataMap.set(doc.id, doc)
      return autoCompleteElementTemplate(doc, query)
    })
    .join("")
}

export function addAutocompletetoFeaturedImage() {
  const form = document.querySelector(
    "form[data-autocomplete-exhibit-catalog-path]"
  )
  if (!form) return

  const autocompletePath = form.dataset.autocompleteExhibitCatalogPath
  const featuredImageTypeaheads = document.querySelectorAll(
    "[data-featured-image-typeahead]"
  )

  if (featuredImageTypeaheads.length === 0) return

  featuredImageTypeaheads.forEach(autoCompleteInput => {
    const autoCompleteElement = autoCompleteInput.closest("auto-complete")

    autoCompleteElement.setAttribute("src", autocompletePath)
    autoCompleteElement.fetchResult = fetchResult
    autoCompleteElement.addEventListener("auto-complete-change", e => {
      const data = getAutoCompleteElementDataMap(autoCompleteElement).get(
        e.relatedTarget.value
      )
      if (!data) return

      const inputElement = e.relatedTarget
      const panel = document.querySelector(inputElement.dataset.targetPanel)
      inputElement.value = data.title

      // Find the ID field using the data attribute
      const idFieldSelector = inputElement.dataset.idField
      const idField = document.querySelector(idFieldSelector)

      // Convert jQuery version of addImageSelector to vanilla JS
      addImageSelector(inputElement, panel, data.iiif_manifest, true)

      // Set the global_id value
      if (idField) {
        idField.value = data["global_id"]
      }

      // Change input type
      inputElement.setAttribute("type", "text")
    })
  })
}

export async function fetchAutocompleteJSON(url) {
  const res = await fetch(url.toString())
  if (!res.ok) {
    throw new Error(await res.text())
  }
  return await res.json()
}
