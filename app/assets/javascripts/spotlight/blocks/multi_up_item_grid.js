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
    caption_key: "item-grid-display-caption",
    field_key: "item-grid-caption-field",
    title_key: "spotlight_title_field",

    type: "multi-up-item-grid",

    title: function() { return "Multi-Up Item Grid"; },

    icon_name: "multi-up-item-grid",

    onBlockRender: function() {
      Spotlight.Block.prototype.onBlockRender.apply();
      this.loadCaptionField();
    },

    afterLoadData: function(data){
      // set a data attribute on the select field so the ajax request knows which option to select
      this.$('select#' + this.formId(this.field_key)).data('select-after-ajax', data[this.field_key]);
    },

    loadCaptionField: function(){
      var block = this;
      var metadata_url = $('form[data-metadata-url]').data('metadata-url');
      var caption_field = $('#' + this.formId(this.field_key));
      var caption_selected_value = caption_field.data("select-after-ajax");
      $.ajax({
        accepts: "json",
        url: metadata_url
      }).success(function(data){
        if($("option", caption_field).length == 2){
          var options = "";
          $.each(data, function(i, field){
            options += block.caption_field_template(field);
          });

          caption_field.append(options);

          caption_field.val([caption_selected_value]);
          // re-serialze the form so the form observer
          // knows about the new drop dwon options.
          serializeFormStatus($('form[data-metadata-url]'));
        }
      });
    },

    caption_field_template: _.template(['<option value="<%= field %>"><%= label %></option>'].join("\n")),

    description: "This widget displays one to five thumbnail images of repository items in a single row grid. Optionally, you can a caption below each image..",

    template: _.template([
    '<div class="form-inline <%= key %>-admin clearfix">',
      '<div class="widget-header">',
        '<%= description %>',
      '</div>',
      '<div class="col-sm-9">',
        '<label for="<%= formId(id_key) %>_0" class="control-label">Selected items to display</label>',
        '<div class="form-group">',
          '<%= buildInputFields(inputFieldsCount) %>',
        '</div>',
      '</div>',
      '<div class="col-sm-3">',
        '<label for="<%= formId(caption_key) %>">',
          '<input name="<%= caption_key %>" id="<%= formId(caption_key) %>" type="checkbox" value="true" />',
          'Display caption',
        '</label>',
        '<div class="field-select">',
          '<label for="<%= formId(field_key) %>">Caption field</label>',
          '<select name="<%= field_key %>" id="<%= formId(field_key) %>">',
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
