//= require spotlight/blocks/resources_block

SirTrevor.Blocks.SolrDocuments = (function(){

  return Spotlight.Block.Resources.extend({
    type: "solr_documents",

    textable: true,

    icon_name: "items",

    autocomplete_url: function() { return this.$instance().closest('form[data-autocomplete-exhibit-catalog-index-path]').data('autocomplete-exhibit-catalog-index-path').replace("%25QUERY", "%QUERY"); },
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

    afterPanelRender: function(data, panel) {
      var context = this;

      if (_.isUndefined(data['image_versions'])) {
        $.getJSON(this.autocomplete_url().replace("%QUERY", "id:" + data.id), function(data) {
          var doc = context.transform_autocomplete_results(data)[0];

          if (!_.isUndefined(doc)) {
            panel.multiImageSelector(doc['image_versions']);
          }
        });
      } else {
        panel.multiImageSelector(data['image_versions']);
      }
    }
  });

})();
