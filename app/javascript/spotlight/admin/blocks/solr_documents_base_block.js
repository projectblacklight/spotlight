import Iiif from "spotlight/admin/iiif"
import Core from "spotlight/core"
import multiImageSelector from "spotlight/admin/multi_image_selector"

SirTrevor.Blocks.SolrDocumentsBase = (function () {
  return Core.Block.Resources.extend({
    plustextable: true,
    autocomplete_url: function () {
      return this.instance().closest(
        "form[data-autocomplete-exhibit-catalog-path]"
      ).dataset.autocompleteExhibitCatalogPath
    },
    autocomplete_template: function (obj) {
      const thumbnail = obj.thumbnail
        ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>`
        : ""
      return `<div class="autocomplete-item${obj.private ? " blacklight-private" : ""}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/><small>&nbsp;&nbsp;${this.highlight(obj.description)}</small></div>`
    },
    transform_autocomplete_results: function (response) {
      return (response["docs"] || []).map(function (doc) {
        return doc
      })
    },

    caption_option_values: function () {
      const element = document.querySelector(
        "[data-blacklight-configuration-index-fields]"
      )
      const fieldsData = element
        ? element.dataset.blacklightConfigurationIndexFields
        : null
      let fields = []
      if (fieldsData) {
        try {
          fields = JSON.parse(fieldsData)
        } catch (e) {
          // ignore
        }
      }

      return fields
        .map(function (field) {
          return `<option value="${field.key}">${field.label}</option>`
        })
        .join("\n")
    },

    item_options: function () {
      return this.caption_options()
    },

    caption_options: function () {
      return `
      <div class="field-select primary-caption" data-behavior="item-caption-admin">
        <input name="${this.show_primary_field_key}" type="hidden" value="false" />
        <input data-input-select-target="#${this.formId(this.primary_field_key)}" name="${this.show_primary_field_key}" id="${this.formId(this.show_primary_field_key)}" type="checkbox" value="true" />
        <label for="${this.formId(this.show_primary_field_key)}">${i18n.t("blocks:solr_documents:caption:primary")}</label>
        <select data-input-select-target="#${this.formId(this.show_primary_field_key)}" name="${this.primary_field_key}" id="${this.formId(this.primary_field_key)}">
          <option value="">${i18n.t("blocks:solr_documents:caption:placeholder")}</option>
          ${this.caption_option_values()}
        </select>
      </div>
      <div class="field-select secondary-caption" data-behavior="item-caption-admin">
        <input name="${this.show_secondary_field_key}" type="hidden" value="false" />
        <input data-input-select-target="#${this.formId(this.secondary_field_key)}" name="${this.show_secondary_field_key}" id="${this.formId(this.show_secondary_field_key)}" type="checkbox" value="true" />
        <label for="${this.formId(this.show_secondary_field_key)}">${i18n.t("blocks:solr_documents:caption:secondary")}</label>
        <select data-input-select-target="#${this.formId(this.show_secondary_field_key)}" name="${this.secondary_field_key}" id="${this.formId(this.secondary_field_key)}">
        <option value="">${i18n.t("blocks:solr_documents:caption:placeholder")}</option>
          ${this.caption_option_values()}
        </select>
      </div>
    `
    },

    // Sets the first version of the IIIF information from autocomplete data.
    _itemPanelIiifFields: function (index, autocomplete_data) {
      var iiifFields = [
        '<input type="hidden" name="item[' +
          index +
          '][thumbnail_image_url]" value="' +
          (autocomplete_data.thumbnail_image_url ||
            autocomplete_data.thumbnail ||
            "") +
          '"/>',
        '<input type="hidden" name="item[' +
          index +
          '][full_image_url]" value="' +
          (autocomplete_data.full_image_url ||
            autocomplete_data.thumbnail_image_url ||
            autocomplete_data.thumbnail ||
            "") +
          '"/>',
        '<input type="hidden" name="item[' +
          index +
          '][iiif_tilesource]" value="' +
          (autocomplete_data.iiif_tilesource || "") +
          '"/>',
        '<input type="hidden" name="item[' +
          index +
          '][iiif_manifest_url]" value="' +
          (autocomplete_data.iiif_manifest_url || "") +
          '"/>',
        '<input type="hidden" name="item[' +
          index +
          '][iiif_canvas_id]" value="' +
          (autocomplete_data.iiif_canvas_id || "") +
          '"/>',
        '<input type="hidden" name="item[' +
          index +
          '][iiif_image_id]" value="' +
          (autocomplete_data.iiif_image_id || "") +
          '"/>'
      ]

      // The region input is required for widgets that enable image cropping but not otherwise
      if (this.show_image_selection) {
        iiifFields.push(
          '<input type="hidden" name="item[' +
            index +
            '][iiif_region]" value="' +
            (autocomplete_data.iiif_region || "") +
            '"/>'
        )
      }

      return iiifFields.join("\n")
    },
    // Overwrites the hidden inputs from _itemPanelIiifFields with data from the
    // manifest. Called by afterPanelRender - the manifest_data here is built
    // from canvases in the manifest, transformed by spotlight/admin/iiif.js in
    // the #images method.
    setIiifFields: function (panel, manifest_data, initialize) {
      if (!panel) return

      const legacyThumbnailField = panel.querySelector(
        '[name$="[thumbnail_image_url]"]'
      )
      const legacyFullField = panel.querySelector('[name$="[full_image_url]"]')

      if (
        initialize &&
        legacyThumbnailField &&
        legacyThumbnailField.value.length > 0
      ) {
        return
      }

      if (legacyThumbnailField) legacyThumbnailField.value = ""
      if (legacyFullField) legacyFullField.value = ""

      const iiifImageIdField = panel.querySelector('[name$="[iiif_image_id]"]')
      if (iiifImageIdField) iiifImageIdField.value = manifest_data.imageId || ""

      const iiifTilesourceField = panel.querySelector(
        '[name$="[iiif_tilesource]"]'
      )
      if (iiifTilesourceField)
        iiifTilesourceField.value = manifest_data.tilesource || ""

      const iiifManifestUrlField = panel.querySelector(
        '[name$="[iiif_manifest_url]"]'
      )
      if (iiifManifestUrlField)
        iiifManifestUrlField.value = manifest_data.manifest || ""

      const iiifCanvasIdField = panel.querySelector('[name$="[iiif_canvas_id]"]')
      if (iiifCanvasIdField)
        iiifCanvasIdField.value = manifest_data.canvasId || ""

      const img = panel.querySelector("img.img-thumbnail")
      if (img) {
        img.src =
          manifest_data.thumbnail_image_url ||
          (manifest_data.tilesource || "").replace(
            "/info.json",
            "/full/100,100/0/default.jpg"
          )
      }
    },
    afterPanelRender: function (data, panel) {
      if (!panel) return

      var context = this
      var manifestUrl = data.iiif_manifest || data.iiif_manifest_url

      if (!manifestUrl) {
        const legacyThumbnailField = panel.querySelector(
          '[name$="[thumbnail_image_url]"]'
        )
        if (legacyThumbnailField) {
          legacyThumbnailField.value =
            data.thumbnail_image_url || data.thumbnail || ""
        }
        const legacyFullField = panel.querySelector('[name$="[full_image_url]"]')
        if (legacyFullField) {
          legacyFullField.value = data.full_image_url || ""
        }

        return
      }

      fetch(manifestUrl)
        .then(function (response) {
          return response.json()
        })
        .then(function (manifest) {
          var iiifManifest = new Iiif(manifestUrl, manifest)

          var thumbs = iiifManifest.imagesArray()

          if (!data.iiif_image_id) {
            context.setIiifFields(panel, thumbs[0], !!data.iiif_manifest_url)
          }

          if (thumbs.length > 1) {
            multiImageSelector(
              panel,
              thumbs,
              function (selectorImage) {
                context.setIiifFields(panel, selectorImage, false)
              },
              data.iiif_image_id
            )
          }
        })
    }
  })
})()
