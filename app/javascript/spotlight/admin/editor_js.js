// esm.sh reliably exposes a default export, but guard against packages that
// only provide named exports (e.g. when the CDN wraps a CJS-only bundle).
import * as EditorJSModule from '@editorjs/editorjs'
import * as HeaderModule from '@editorjs/header'
import * as TOCModule from '@phigoro/editorjs-toc'
import SolrDocumentsTool from 'spotlight/admin/editor_js/tools/solr_documents_tool'

const EditorJS = EditorJSModule.default ?? EditorJSModule.EditorJS ?? EditorJSModule
const Header = HeaderModule.default ?? HeaderModule.Header ?? HeaderModule
const TOC = TOCModule.default ?? TOCModule.TOC ?? TOCModule

export default class {
  connect() {
    const textarea = document.querySelector('.js-editorjs-instance')
    if (!textarea) return

    // Parse stored EditorJS JSON or start empty
    let initialData = { blocks: [] }
    try {
      const raw = JSON.parse(textarea.value)
      if (raw && Array.isArray(raw.blocks)) initialData = raw
    } catch {} // eslint-disable-line no-empty

    // Read catalog-specific config from the form's data attributes (set by
    // PageConfigurations#as_json and rendered into the <form> element).
    const form = textarea.closest('form')
    const autocompleteUrl = form?.dataset.autocompleteExhibitCatalogPath || ''
    const captionFields   = JSON.parse(form?.dataset.blacklightConfigurationIndexFields || '[]')

    // Create a visible holder div adjacent to the hidden textarea
    const holder = document.createElement('div')
    holder.id = 'editorjs-holder'
    holder.className = 'editorjs-holder'
    textarea.style.display = 'none'
    textarea.parentNode.insertBefore(holder, textarea.nextSibling)

    const editor = new EditorJS({
      holder: 'editorjs-holder',
      tools: {
        header: {
          class: Header,
          config: { levels: [2, 3, 4], defaultLevel: 2 }
        },
        toc: {
          class: TOC
        },
        // Custom Spotlight widget — mirrors the Sir Trevor SolrDocuments block
        solr_documents: {
          class: SolrDocumentsTool,
          config: { autocompleteUrl, captionFields }
        }
      },
      data: initialData
    })

    // Before the form submits, serialize EditorJS output into the textarea
    if (!form) return

    let saving = false
    form.addEventListener('submit', async (e) => {
      if (saving) return
      e.preventDefault()
      saving = true
      try {
        const outputData = await editor.save()
        textarea.value = JSON.stringify(outputData)
      } catch (err) {
        saving = false
        console.error('EditorJS save failed:', err)
        return
      }
      form.requestSubmit(e.submitter || null)
    })
  }
}
