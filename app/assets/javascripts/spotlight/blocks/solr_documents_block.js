//= require spotlight/blocks/resources_block

SirTrevor.Blocks.SolrDocuments = (function(){

  return Spotlight.Block.Resources.extend({
    type: "solr_documents",

    plustextable: true,

    icon_name: "items",

    autocomplete_url: function() { return this.$instance().closest('form[data-autocomplete-exhibit-catalog-path]').data('autocomplete-exhibit-catalog-path').replace("%25QUERY", "%QUERY"); },
    autocomplete_template: function() { return '<div class="autocomplete-item{{#if private}} blacklight-private{{/if}}">{{#if thumbnail}}<div class="document-thumbnail thumbnail"><img src="{{thumbnail}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' },

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

    caption_options: function() { return [
      '<div class="field-select primary-caption" data-behavior="item-caption-admin">',
        '<input name="<%= show_primary_field_key %>" type="hidden" value="false" />',
        '<input data-input-select-target="#<%= formId(primary_field_key) %>" name="<%= show_primary_field_key %>" id="<%= formId(show_primary_field_key) %>" type="checkbox" value="true" />',
        '<label for="<%= formId(show_primary_field_key) %>"><%= i18n.t("blocks:solr_documents:caption:primary") %></label>',
        '<select data-input-select-target="#<%= formId(show_primary_field_key) %>" name="<%= primary_field_key %>" id="<%= formId(primary_field_key) %>">',
          '<option value=""><%= i18n.t("blocks:solr_documents:caption:placeholder") %></option>',
          '<%= caption_option_values() %>',
        '</select>',
      '</div>',
      '<div class="field-select secondary-caption" data-behavior="item-caption-admin">',
        '<input name="<%= show_secondary_field_key %>" type="hidden" value="false" />',
        '<input data-input-select-target="#<%= formId(secondary_field_key) %>" name="<%= show_secondary_field_key %>" id="<%= formId(show_secondary_field_key) %>" type="checkbox" value="true" />',
        '<label for="<%= formId(show_secondary_field_key) %>"><%= i18n.t("blocks:solr_documents:caption:secondary") %></label>',
        '<select data-input-select-target="#<%= formId(show_secondary_field_key) %>" name="<%= secondary_field_key %>" id="<%= formId(secondary_field_key) %>">',
        '<option value=""><%= i18n.t("blocks:solr_documents:caption:placeholder") %></option>',
          '<%= caption_option_values() %>',
        '</select>',
      '</div>',
    ].join("\n") },

    _itemPanelIiifFields: function(index, data) {
      return [
        // '<input type="hidden" name="item[' + index + '][iiif_region]" value="' + (data.iiif_region) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_tilesource]" value="' + (data.iiif_tilesource) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_manifest_url]" value="' + (data.iiif_manifest_url) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_canvas_id]" value="' + (data.iiif_canvas_id) + '"/>',
        '<input type="hidden" name="item[' + index + '][iiif_image_id]" value="' + (data.iiif_image_id) + '"/>',
      ].join("\n");
    },
    setIiifFields: function(data) {
      $(this.inner).find('[name$="[iiif_image_id]"]').val(data.imageId);
      $(this.inner).find('[name$="[iiif_tilesource]"]').val(data.tilesource);
      $(this.inner).find('[name$="[iiif_manifest_url]"]').val(data.manifest);
      $(this.inner).find('[name$="[iiif_canvas_id]"]').val(data.canvasId);
    },
    afterPanelRender: function(data, panel) {
      var context = this;
      var manifestUrl = data.iiif_manifest || data.iiif_manifest_url;

      $.ajax(manifestUrl).success(
        function(manifest) {
          var thumbs = [];
          manifest.sequences.forEach(function(sequence) {
            sequence.canvases.forEach(function(canvas) {
              canvas.images.forEach(function(image) {
                var iiifService = image.resource.service['@id'];
                thumbs.push(
                  {
                    'thumb': iiifService + '/full/!100,100/0/default.jpg',
                    'tilesource': iiifService + '/info.json',
                    'manifest': manifestUrl,
                    'canvasId': canvas['@id'],
                    'imageId': image['@id']
                  }
                );
              });
            });
          });

          if (!data.iiif_manifest_url) {
            context.setIiifFields(thumbs[0]);
          }
          if(thumbs.length > 1) {
            panel.multiImageSelector(thumbs, function(selectorImage) {
              context.setIiifFields(selectorImage);
            });
          }
        }
      );
    }
  });

})();
