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

    toData: function() {
      var data = {};
      this.$('.item-grid-input').each(function(){
        data[$(this).attr("id")] = $(this).val();
      });
      this.$('.item-grid-checkbox').each(function(){
        data[$(this).attr("id")] = $("[name='" + $(this).attr('name') + "']:checked").val();
      });
      data[this.caption_key] = this.$('[name=' + this.caption_key + ']:checked').val();
      data[this.field_key] = this.$('[name=' + this.field_key + '] option:selected').val();
      this.setData(data);
    },

    onBlockRender: function() {
      Spotlight.Block.prototype.onBlockRender.apply();
      this.loadCaptionField();
    },

    loadData: function(data){
      this.$('.item-grid-input').each(function(){
        $(this).val(data[$(this).attr("id")]);
      });
      this.$('.item-grid-checkbox').each(function(){
        $(this).prop('checked', data[$(this).attr("id")]);
      });
      this.$('#' + this.formId(this.caption_key)).prop('checked', data[this.caption_key])
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
            var selected = ""
            if (field.field == caption_selected_value) {
              selected = " selected"
            }
            options += "<option " + selected + " value='" + field.field + "'>" + field.label + "</option>";
          });
          if(caption_selected_value == block.title_key){
            $("option[value='" + block.title_key + "']", caption_field).prop("selected", true);
          }
          caption_field.append(options);
          // re-serialze the form so the form observer
          // knows about the new drop dwon options.
          serializeFormStatus($('form[data-metadata-url]'));
        }
      });
    },

    template: _.template([
    '<div class="form-inline <%= key %>-admin">',
      '<div class="widget-header">',
        'This widget displays one to five thumbnail images of repository items in a single row grid. Optionally, you can a caption below each image..',
      '</div>',
      '<div class="col-sm-9">',
        '<label for="<%= formId(id_key) %>_0" class="control-label">Selected items to display</label>',
        '<div class="form-group">',
          buildInputFields(5),
        '</div>',
      '</div>',
      '<div class="col-sm-3">',
        '<label for="<%= formId(caption_key) %>">',
          '<input name="<%= caption_key %>" type="hidden" value="false" />',
          '<input name="<%= caption_key %>" id="<%= formId(caption_key) %>" type="checkbox" value="true" />',
          'Display caption',
        '</label>',
        '<div class="field-select">',
          '<label for="<%= formId(field_key) %>">Caption field</label>',
          '<select name="<%= field_key %>" id="<%= formId(field_key) %>">',
            '<option value="">Select...</option>',
            '<option value="<%= title_key %>">Title</option>',
          '</select>',
        '</div>',
      '</div>',
      '<div class="clearFix"></div>',
    '</div>'
  ].join("\n"))
  });
})();
function buildInputFields(times){
  output = ""
  for(var i=0; i < times; i++){
    output += '<div class="col-sm-9 field">';
      output += '<input name="<%= display_checkbox + "_' + i + '" %>" type="hidden" value="false" />';
      output += '<input name="<%= display_checkbox + "_' + i + '" %>" id="<%= formId(display_checkbox + "_' + i + '") %>" type="checkbox" class="item-grid-checkbox" value="true" />';
      output += '<input name="<%= id_key + "_' + i + '" %>" class="item-grid-input" type="hidden" id="<%= formId(id_key + "_' + i + '") %>" />';
      output += '<input data-checkbox_field="#<%= formId(display_checkbox + "_' + i + '") %>" data-id_field="#<%= formId(id_key + "_' + i + '") %>" name="<%= id_key + "_' + i + '_title" %>" class="st-input-string item-grid-input form-control" data-twitter-typeahead="true" type="text" id="<%= formId(id_key + "_' + i + '_title") %>" />';
    output += '</div>';
  }
  return output;
}
