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
  const autocompletePath = $(
    "form[data-autocomplete-exhibit-catalog-path]"
  ).data("autocomplete-exhibit-catalog-path")
  const featuredImageTypeaheads = $("[data-featured-image-typeahead]")
  if (featuredImageTypeaheads.length === 0) return

  $.each(featuredImageTypeaheads, function (index, autoCompleteInput) {
    const autoCompleteElement = autoCompleteInput.closest("auto-complete")

    autoCompleteElement.setAttribute("src", autocompletePath)
    autoCompleteElement.fetchResult = fetchResult
    autoCompleteElement.addEventListener("auto-complete-change", e => {
      const data = getAutoCompleteElementDataMap(autoCompleteElement).get(
        e.relatedTarget.value
      )
      if (!data) return

      const inputElement = $(e.relatedTarget)
      const panel = document.querySelector(e.relatedTarget.dataset.targetPanel)
      e.relatedTarget.value = data.title
      addImageSelector(inputElement[0], panel, data.iiif_manifest, true)
      $(inputElement.data("id-field")).val(data["global_id"])
      inputElement.attr("type", "text")
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
