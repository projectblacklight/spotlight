/*
  Sir Trevor MutliUpItemGrid Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title,
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.MultiUpItemGrid =  (function(){
  var key = "item-grid"
  var id_key = key + "-id";
  var display_checkbox = key + "-display";
  var caption_key = key + "-display-caption";
  var field_key = key + "caption-field";
  var max_fields = 5;
  var type = "multi-up-item-grid";

  var template = _.template([
    '<div class="form-inline ' + key + '-admin">',
      '<div class="widget-header">',
        'This widget displays one to five thumbnail images of repository items in a single row grid. Optionally, you can a caption below each image..',
      '</div>',
      '<div class="col-sm-9">',
        '<label for="' + id_key + '_0" class="control-label">Selected items to display</label>',
        '<div class="form-group">',
          buildInputFields(max_fields, id_key, display_checkbox),
        '</div>',
      '</div>',
      '<div class="col-sm-3">',
        '<label for"' + caption_key + '">',
          '<input name="' + caption_key + '" type="hidden" value="false" />',
          '<input name="' + caption_key + '" id="' + caption_key + '" type="checkbox" value="true" />',
          'Display caption',
        '</label>',
        '<div class="field-select">',
          '<label for="' + field_key + '">Caption field</label>',
          '<select name="' + field_key + '" id="' + field_key + '">',
            '<option value="title">Title</option>',
          '</select>',
        '</div>',
      '</div>',
      '<div class="clearFix"></div>',
    '</div>'
  ].join("\n"));

  return SirTrevor.Block.extend({

    type: type,

    title: function() { return "Multi-Up Item Grid"; },

    editorHTML: function() {
      return template(this);
    },

    icon_name: type,

    toData: function() {
      var data = {};
      this.$('.item-grid-input').each(function(){
        data[$(this).attr("id")] = $(this).val();
      });
      this.$('.item-grid-checkbox').each(function(){
        data[$(this).attr("id")] = $("[name='" + $(this).attr('name') + "']:checked").val();
      });
      data[caption_key] = this.$('[name=' + caption_key + ']:checked').val();
      this.setData(data);
    },

    onBlockRender: function() {
      addAutocompletetoSirTrevorForm();
    },

    loadData: function(data){
      this.$('.item-grid-input').each(function(){
        $(this).val(data[$(this).attr("id")]);
      });
      this.$('.item-grid-checkbox').each(function(){
        $(this).prop('checked', data[$(this).attr("id")]);
      });
      this.$('#' + caption_key).prop('checked', data[caption_key])
    }
  });
})();
function buildInputFields(times, id, checkbox){
  output = ""
  for(var i=0; i < times; i++){
    output += '<div class="col-sm-9 field">';
      output += '<input name="' + checkbox + '_' + i + '" type="hidden" value="false" />';
      output += '<input name="' + checkbox + '_' + i + '" id="' + checkbox + '_' + i + '" type="checkbox" class="item-grid-checkbox" value="true" />';
      output += '<input name="' + id + '_' + i + '" class="st-input-string item-grid-input form-control" data-twitter-typeahead="true" type="text" id="' + id + '_' + i + '" />';
    output += '</div>';
  }
  return output;
}
