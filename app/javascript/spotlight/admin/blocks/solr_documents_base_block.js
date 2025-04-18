import Iiif from 'spotlight/admin/iiif'
import Core from 'spotlight/core'

SirTrevor.Blocks.SolrDocumentsBase = (function(){

  return Core.Block.Resources.extend({
    plustextable: true,
    autocomplete_url: function() { return this.$instance().closest('form[data-autocomplete-exhibit-catalog-path]').data('autocomplete-exhibit-catalog-path') },
    autocomplete_template: function(obj) {
      const thumbnail = obj.thumbnail ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>` : ''
      return `<div class="autocomplete-item${obj.private ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/><small>&nbsp;&nbsp;${this.highlight(obj.description)}</small></div>`
    },
    transform_autocomplete_results: function(response) {
      return $.map(response['docs'], function(doc) {
        return doc;
      })
    },

    caption_option_values: function() {
      var fields = $('[data-blacklight-configuration-index-fields]').data('blacklight-configuration-index-fields');

      return $.map(fields, function(field) {
        return $('<option />').val(field.key).text(field.label)[0].outerHTML;
      }).join("\n");
    },

    item_options: function() { return this.caption_options(); },

    caption_options: function() { return `
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
    `},

    // Sets the first version of the IIIF information from autocomplete data.
    _itemPanelIiifFields: function(index, autocomplete_data) {
      var iiifFields = [
        '<input type="hidden" name="item[' + index + '][thumbnail_image_url]" value="' + (autocomplete_data.thumbnail_image_url || autocomplete_data.thumbnail || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][full_image_url]" value="' + (autocomplete_data.full_image_url || autocomplete_data.thumbnail_image_url || autocomplete_data.thumbnail || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_tilesource]" value="' + (autocomplete_data.iiif_tilesource || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_manifest_url]" value="' + (autocomplete_data.iiif_manifest_url || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_canvas_id]" value="' + (autocomplete_data.iiif_canvas_id || "") + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_image_id]" value="' + (autocomplete_data.iiif_image_id || "") + '"/>',
      ];

      // The region input is required for widgets that enable image cropping but not otherwise
      if(this.show_image_selection) {
        iiifFields.push('<input type="hidden" name="item[' + index + '][iiif_region]" value="' + (autocomplete_data.iiif_region || "") + '"/>');
      }

      return iiifFields.join("\n");
    },
    // Overwrites the hidden inputs from _itemPanelIiifFields with data from the
    // manifest. Called by afterPanelRender - the manifest_data here is built
    // from canvases in the manifest, transformed by spotlight/admin/iiif.js in
    // the #images method.
    setIiifFields: function(panel, manifest_data, initialize) {
      var legacyThumbnailField = $(panel).find('[name$="[thumbnail_image_url]"]')
      var legacyFullField = $(panel).find('[name$="[full_image_url]"]')

      if (initialize && legacyThumbnailField.val().length > 0) {
        return;
      }

      legacyThumbnailField.val("");
      legacyFullField.val("");
      $(panel).find('[name$="[iiif_image_id]"]').val(manifest_data.imageId);
      $(panel).find('[name$="[iiif_tilesource]"]').val(manifest_data.tilesource);
      $(panel).find('[name$="[iiif_manifest_url]"]').val(manifest_data.manifest);
      $(panel).find('[name$="[iiif_canvas_id]"]').val(manifest_data.canvasId);
      $(panel).find('img.img-thumbnail').attr('src', manifest_data.thumbnail_image_url || manifest_data.tilesource.replace("/info.json", "/full/100,100/0/default.jpg"));
    },
    afterPanelRender: function(data, panel) {
      var context = this;
      var manifestUrl = data.iiif_manifest || data.iiif_manifest_url;

      if (!manifestUrl) {
        $(panel).find('[name$="[thumbnail_image_url]"]').val(data.thumbnail_image_url || data.thumbnail);
        $(panel).find('[name$="[full_image_url]"]').val(data.full_image_url);

        return;
      }

      $.ajax(manifestUrl).done(
        function(manifest) {
          var iiifManifest = new Iiif(manifestUrl, manifest);

          var thumbs = iiifManifest.imagesArray();

          if (!data.iiif_image_id) {
            context.setIiifFields(panel, thumbs[0], !!data.iiif_manifest_url);
          }


          if(thumbs.length > 1) {
            panel.multiImageSelector(thumbs, function(selectorImage) {
              context.setIiifFields(panel, selectorImage, false);
            }, data.iiif_image_id);
          }
        }
      );
    }
  });

})();
