/*
  Sir Trevor MutliUpItemGrid Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title,
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.MultiUpItemGrid =  (function(){
  
  return Spotlight.Block.extend({

    key: "item-grid",
    id_key: "item-grid-id",
    display_checkbox: "item-grid-display",
    primary_field_key: "item-grid-primary-caption-field",
    show_primary_caption: "show-primary-caption",
    secondary_field_key: "item-grid-secondary-caption-field",
    show_secondary_caption: "show-secondary-caption",
    title_key: "spotlight_title_field",

    type: "multi-up-item-grid",

    title: function() { return "Multi-Up Item Grid"; },

    icon_name: "multi-up-item-grid",

    onBlockRender: function() {
      Spotlight.Block.prototype.onBlockRender.apply();
      this.loadCaptionField();
    },

    afterLoadData: function(data){
      // set a data attribute on the select fields so the ajax request knows which option to select
      this.$('select#' + this.formId(this.primary_field_key)).data('select-after-ajax', data[this.primary_field_key]);
      this.$('select#' + this.formId(this.secondary_field_key)).data('select-after-ajax', data[this.secondary_field_key]);
    },

    description: "This widget displays one to five thumbnail images of repository items in a single row grid. Optionally, you can a caption below each image..",

    template: _.template([
    '<div class="form-inline <%= key %>-admin clearfix">',
      '<div class="widget-header">',
        '<%= description %>',
      '</div>',
      '<div class="col-sm-8">',
        '<label for="<%= formId(id_key) %>_0" class="control-label">Selected items to display</label>',
        '<div class="form-group">',
          '<%= buildInputFields(inputFieldsCount) %>',
        '</div>',
      '</div>',
      '<div class="col-sm-4">',
        '<div class="field-select primary-caption">',
          '<input name="<%= show_primary_caption %>" id="<%= formId(show_primary_caption) %>" type="checkbox" value="true" />',
          '<label for="<%= formId(primary_field_key) %>">Primary caption</label>',
          '<select name="<%= primary_field_key %>" id="<%= formId(primary_field_key) %>">',
            '<option value="">Select...</option>',
            '<%= caption_field_template({field: title_key, label: "Title", selected: ""}) %>',
          '</select>',
        '</div>',
        '<div class="field-select secondary-caption">',
          '<input name="<%= show_secondary_caption %>" id="<%= formId(show_secondary_caption) %>" type="checkbox" value="true" />',
          '<label for="<%= formId(secondary_field_key) %>">Secondary caption</label>',
          '<select name="<%= secondary_field_key %>" id="<%= formId(secondary_field_key) %>">',
            '<option value="">Select...</option>',
            '<%= caption_field_template({field: title_key, label: "Title", selected: ""}) %>',
          '</select>',
        '</div>',
      '</div>',
    '</div>'
  ].join("\n")),

  inputFieldsCount: 5,

  buildInputFields: function(times) {
    output = '<input type="hidden" name="<%= id_key %>_count" value="' + times + '"/>';
    for(var i=0; i < times; i++){
      output += '<div class="col-sm-9 field">';
        output += '<input name="<%= display_checkbox + "_' + i + '" %>" id="<%= formId(display_checkbox + "_' + i + '") %>" type="checkbox" class="item-grid-checkbox" value="true" />';
        output += '<input name="<%= id_key + "_' + i + '" %>" class="item-grid-input" type="hidden" id="<%= formId(id_key + "_' + i + '") %>" />';
        output += '<input data-checkbox_field="#<%= formId(display_checkbox + "_' + i + '") %>" data-id_field="#<%= formId(id_key + "_' + i + '") %>" name="<%= id_key + "_' + i + '_title" %>" class="st-input-string item-grid-input form-control" data-twitter-typeahead="true" type="text" id="<%= formId(id_key + "_' + i + '_title") %>" />';
      output += '</div>';
    }
    return _.template(output)(this);
  }
  });
})();
