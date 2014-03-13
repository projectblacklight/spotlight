/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.ItemText =  (function(){

  return Spotlight.Block.extend({

    id_key:"item-id",
    id_text_key:"item-text-id",
    title_key: "spotlight_title_field",
    primary_field_key: "item-grid-primary-caption-field",
    show_primary_field_key: "show-primary-caption",
    secondary_field_key: "item-grid-secondary-caption-field",
    show_secondary_field_key: "show-secondary-caption",
    text_key:"item-text",
    align_key:"text-align",

    type: "item-text",

    title: function() { return "Item + Text"; },

    icon_name: "item-text",

    onBlockRender: function() {
      Spotlight.Block.prototype.onBlockRender.apply();
      $('#' + this.formId(this.id_text_key)).focus();
      this.loadCaptionField();
    },

    afterLoadData: function(data){
      // set a data attribute on the select fields so the ajax request knows which option to select
      this.$('select#' + this.formId(this.primary_field_key)).data('select-after-ajax', data[this.primary_field_key]);
      this.$('select#' + this.formId(this.secondary_field_key)).data('select-after-ajax', data[this.secondary_field_key]);
    },

    template: _.template([
    '<div class="form-horizontal item-text-admin">',
      '<div class="widget-header">',
        'This widget displays a thumbnail image of the repository item you selected and a text block to the left or right of it.',
      '</div>',
      '<div class="col-sm-8">',
        '<div class="form-group">',
          '<label for="<%= formId(id_text_key) %>" class="col-sm-2 control-label">Selected item</label>',
          '<div class="col-sm-6 field">',
            '<input data-id_field="#<%= formId(id_key) %>" name="<%= id_text_key %>"',
            ' class="st-input-string form-control <%= type %>" type="text" id="<%= formId(id_text_key) %>" data-twitter-typeahead="true" />',
            '<input name="<%= id_key %>" type="hidden" id="<%= formId(id_key) %>" />',
          '</div>',
        '</div>',
        '<div class="form-group">',
          '<label for="<%= formId(text_key) %>" class="col-sm-2 control-label">Text</label>',
          '<div class="col-sm-6 field">',
          '<div id="<%= formId(text_key) %>" class="st-text-block" contenteditable="true"></div>',
          '</div>',
        '</div>',
      '</div>',
      '<div class="col-sm-4">',
        '<div class="field-select primary-caption">',
          '<input name="<%= show_primary_field_key %>" id="<%= formId(show_primary_field_key) %>" type="checkbox" value="true" />',
          '<label for="<%= formId(primary_field_key) %>">Primary caption</label>',
          '<select name="<%= primary_field_key %>" id="<%= formId(primary_field_key) %>">',
            '<option value="">Select...</option>',
            '<%= caption_field_template({field: title_key, label: "Title", selected: ""}) %>',
          '</select>',
        '</div>',
        '<div class="field-select secondary-caption">',
          '<input name="<%= show_secondary_field_key %>" id="<%= formId(show_secondary_field_key) %>" type="checkbox" value="true" />',
          '<label for="<%= formId(secondary_field_key) %>">Secondary caption</label>',
          '<select name="<%= secondary_field_key %>" id="<%= formId(secondary_field_key) %>">',
            '<option value="">Select...</option>',
            '<%= caption_field_template({field: title_key, label: "Title", selected: ""}) %>',
          '</select>',
        '</div>',
        '<div class="text-align">',
          '<p>Display text on:</p>',
          '<input data-key="<%= align_key %>" type="radio" name="<%= formId(align_key) %>" id="<%= formId(align_key + "-right") %>" value="right" checked="true">',
          '<label for="<%= formId(align_key + "-right") %>">Left</label>',
          '<input data-key="<%= align_key %>" type="radio" name="<%= formId(align_key) %>" id="<%= formId(align_key + "-left") %>" value="left">',
          '<label for="<%= formId(align_key + "-left") %>">Right</label>',
        '</div>',
      '</div>',
      '<div class="clearFix"></div>',
    '</div>'
  ].join("\n"))
  });
})();