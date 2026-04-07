import * as SortableModule from 'sortablejs'
import { fetchAutocompleteJSON } from 'spotlight/admin/search_typeahead'

const Sortable = SortableModule.default ?? SortableModule

/**
 * Editor.js block tool that mirrors the Sir Trevor SolrDocuments (item row) widget.
 *
 * Saved data shape:
 * {
 *   items: [{ id, title, display, weight, thumbnail_image_url, full_image_url,
 *             iiif_tilesource, iiif_manifest_url, iiif_canvas_id, iiif_image_id }],
 *   show_primary_caption:    boolean,
 *   primary_caption_field:   string,
 *   show_secondary_caption:  boolean,
 *   secondary_caption_field: string,
 *   zpr_link:                boolean
 * }
 *
 * Config (passed from editor_js.js):
 *   autocompleteUrl  – autocomplete-exhibit-catalog-path
 *   captionFields    – [{ key, label }] from blacklight-configuration-index-fields
 */
export default class SolrDocumentsTool {
  // ----- Editor.js static API -----------------------------------------------

  static get toolbox() {
    return {
      title: 'Item Row',
      icon: `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="16" height="16">
               <path d="M4 6h16M4 10h16M4 14h16M4 18h16" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" fill="none"/>
             </svg>`
    }
  }

  static get isReadOnlySupported() { return true }

  // ----- Lifecycle -----------------------------------------------------------

  constructor({ data, config, api, readOnly }) {
    this._api      = api
    this._readOnly = readOnly
    this._config   = config || {}
    this._fetchedDocs = {}

    // Normalise stored data, keeping sensible defaults
    this._data = {
      items:                   data.items                   || [],
      show_primary_caption:    data.show_primary_caption    ?? false,
      primary_caption_field:   data.primary_caption_field   || '',
      show_secondary_caption:  data.show_secondary_caption  ?? false,
      secondary_caption_field: data.secondary_caption_field || '',
      zpr_link:                data.zpr_link                ?? false
    }

    this._wrapper = null
  }

  render() {
    this._wrapper = document.createElement('div')
    this._wrapper.classList.add('editorjs-solr-documents')

    if (this._readOnly) {
      this._renderReadOnly()
    } else {
      this._renderEditor()
    }

    return this._wrapper
  }

  save(blockContent) {
    const items = []
    blockContent.querySelectorAll('[data-item-id]').forEach((li, index) => {
      const raw  = JSON.parse(li.querySelector('[data-item-json]').value)
      const display = li.querySelector('[data-display-check]').checked
      items.push({ ...raw, display, weight: index })
    })

    return {
      items,
      show_primary_caption:    blockContent.querySelector('[data-show-primary-caption]')?.checked    ?? false,
      primary_caption_field:   blockContent.querySelector('[data-primary-caption-field]')?.value     || '',
      show_secondary_caption:  blockContent.querySelector('[data-show-secondary-caption]')?.checked  ?? false,
      secondary_caption_field: blockContent.querySelector('[data-secondary-caption-field]')?.value   || '',
      zpr_link:                blockContent.querySelector('[data-zpr-link]')?.checked                ?? false
    }
  }

  // ----- Private: editor rendering ------------------------------------------

  _renderEditor() {
    const { autocompleteUrl, captionFields = [] } = this._config
    const acId = `ejs-solr-docs-${Date.now()}`

    this._wrapper.innerHTML = `
      <div class="editorjs-solr-documents__header">
        <strong>Item Row</strong>
      </div>

      <ol class="editorjs-solr-documents__list" data-item-list></ol>

      <div class="editorjs-solr-documents__search-row">
        <auto-complete src="${autocompleteUrl}" for="${acId}-popup" fetch-on-empty>
          <input type="text"
                 class="editorjs-solr-documents__search-input"
                 placeholder="Search catalog to add items…"
                 autocomplete="off" />
          <ul id="${acId}-popup" class="editorjs-solr-documents__popup" role="listbox"></ul>
        </auto-complete>
      </div>

      <div class="editorjs-solr-documents__options">
        ${this._captionOptionsHTML(captionFields)}
        ${this._zprOptionHTML()}
      </div>
    `

    // Re-populate items saved in a previous session
    this._data.items
      .slice()
      .sort((a, b) => (a.weight ?? 0) - (b.weight ?? 0))
      .forEach(item => this._appendItemPanel(item))

    this._restoreOptionValues()
    this._bindAutocomplete(acId)

    // Drag-to-reorder via SortableJS
    Sortable.create(this._wrapper.querySelector('[data-item-list]'), {
      animation:   150,
      handle:      '.editorjs-solr-documents__drag',
      ghostClass:  'editorjs-solr-documents__ghost'
    })
  }

  _renderReadOnly() {
    const count = this._data.items.filter(i => i.display !== false).length
    this._wrapper.innerHTML = `
      <div class="editorjs-solr-documents editorjs-solr-documents--readonly">
        <em>Item Row — ${count} item${count !== 1 ? 's' : ''}</em>
      </div>`
  }

  // ----- Private: item panels -----------------------------------------------

  _appendItemPanel(item) {
    const list = this._wrapper.querySelector('[data-item-list]')
    const li   = document.createElement('li')
    li.classList.add('editorjs-solr-documents__item')
    li.dataset.itemId = item.id

    const checked  = item.display !== false ? 'checked' : ''
    const thumbSrc = item.thumbnail_image_url || ''
    const thumb    = thumbSrc
      ? `<img src="${thumbSrc}" class="editorjs-solr-documents__thumb" alt="" />`
      : `<span class="editorjs-solr-documents__no-thumb">No image</span>`

    li.innerHTML = `
      <span class="editorjs-solr-documents__drag" title="Drag to reorder">⠿</span>
      <label class="editorjs-solr-documents__display">
        <input type="checkbox" data-display-check ${checked} title="Display this item" />
      </label>
      ${thumb}
      <span class="editorjs-solr-documents__title">${this._escapeHTML(item.title || item.id)}</span>
      <button type="button" class="editorjs-solr-documents__remove" title="Remove item">×</button>
      <input type="hidden" data-item-json value="${this._escapeAttr(JSON.stringify(item))}" />
    `

    li.querySelector('.editorjs-solr-documents__remove')
      .addEventListener('click', () => li.remove())

    list.appendChild(li)
  }

  // ----- Private: caption + ZPR options -------------------------------------

  _captionOptionsHTML(captionFields) {
    const optionsHTML = captionFields.map(f =>
      `<option value="${this._escapeAttr(f.key)}">${this._escapeHTML(f.label)}</option>`
    ).join('')

    return `
      <div class="editorjs-solr-documents__caption-group">
        <label class="editorjs-solr-documents__caption-label">
          <input type="checkbox" data-show-primary-caption />
          Primary caption:
          <select data-primary-caption-field>
            <option value="">— none —</option>
            ${optionsHTML}
          </select>
        </label>
        <label class="editorjs-solr-documents__caption-label">
          <input type="checkbox" data-show-secondary-caption />
          Secondary caption:
          <select data-secondary-caption-field>
            <option value="">— none —</option>
            ${optionsHTML}
          </select>
        </label>
      </div>`
  }

  _zprOptionHTML() {
    return `
      <label class="editorjs-solr-documents__zpr-label">
        <input type="checkbox" data-zpr-link />
        Enable zoom / pan / rotate link (IIIF items only)
      </label>`
  }

  _restoreOptionValues() {
    const d = this._data

    const showPrimary = this._wrapper.querySelector('[data-show-primary-caption]')
    const primaryField = this._wrapper.querySelector('[data-primary-caption-field]')
    if (showPrimary) showPrimary.checked = !!d.show_primary_caption
    if (primaryField && d.primary_caption_field) primaryField.value = d.primary_caption_field

    const showSecondary = this._wrapper.querySelector('[data-show-secondary-caption]')
    const secondaryField = this._wrapper.querySelector('[data-secondary-caption-field]')
    if (showSecondary) showSecondary.checked = !!d.show_secondary_caption
    if (secondaryField && d.secondary_caption_field) secondaryField.value = d.secondary_caption_field

    const zpr = this._wrapper.querySelector('[data-zpr-link]')
    if (zpr) zpr.checked = !!d.zpr_link
  }

  // ----- Private: autocomplete ----------------------------------------------

  _bindAutocomplete(acId) {
    const autoComplete = this._wrapper.querySelector('auto-complete')
    if (!autoComplete) return

    // Provide a custom fetchResult that calls the catalog autocomplete endpoint
    // and returns list-item HTML (the auto-complete-element contract).
    autoComplete.fetchResult = async (url) => {
      const json = await fetchAutocompleteJSON(url)
      const docs = json.docs || []
      this._fetchedDocs = {}
      return docs.map(doc => {
        this._fetchedDocs[doc.id] = doc
        const thumb = doc.thumbnail
          ? `<img src="${doc.thumbnail}" class="editorjs-solr-documents__ac-thumb" alt="" />`
          : ''
        return `<li role="option" data-autocomplete-value="${doc.id}">
                  <div class="editorjs-solr-documents__ac-item">
                    ${thumb}
                    <span>${this._escapeHTML(doc.title || doc.id)}</span>
                  </div>
                </li>`
      }).join('')
    }

    autoComplete.addEventListener('auto-complete-change', (e) => {
      const doc = this._fetchedDocs[e.relatedTarget.value]
      if (!doc) return
      e.relatedTarget.value = ''        // clear the search input
      this._appendItemPanel({
        id:                  doc.id,
        title:               doc.title                || '',
        display:             true,
        thumbnail_image_url: doc.thumbnail_image_url  || doc.thumbnail || '',
        full_image_url:      doc.full_image_url        || '',
        iiif_tilesource:     doc.iiif_tilesource       || '',
        iiif_manifest_url:   doc.iiif_manifest_url     || '',
        iiif_canvas_id:      doc.iiif_canvas_id        || '',
        iiif_image_id:       doc.iiif_image_id         || ''
      })
    })
  }

  // ----- Private: helpers ---------------------------------------------------

  _escapeHTML(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
  }

  _escapeAttr(str) {
    return String(str).replace(/"/g, '&quot;').replace(/'/g, '&#39;')
  }
}
