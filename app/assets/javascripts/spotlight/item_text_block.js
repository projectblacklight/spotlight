/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.ItemText =  (function(){

  var id_key = "item-id";
  var id_text_key = "item-text-id";
  var title_key = "show-title";
  var text_key = "item-text"
  var align_key = "text-align"

  var type = "item-text";

  var template = _.template([
    '<div class="form-horizontal item-text-admin">',
      '<div class="widget-header">',
        'This widget displays a thumbnail image of the repository item you selected and a text block to the left or right of it.',
      '</div>',
      '<div class="col-sm-9">',
        '<div class="form-group">',
          '<label for="' + id_text_key + '" class="col-sm-2 control-label">Selected item</label>',
          '<div class="col-sm-6 field">',
            '<input data-id_field="#' + id_key + '" name="' + id_text_key + '"',
            ' class="st-input-string form-control ' + type + '" type="text" id="' + id_text_key + '" data-twitter-typeahead="true" />',
            '<input name="' + id_key + '" type="hidden" id="' + id_key + '" />',
          '</div>',
        '</div>',
        '<div class="form-group">',
          '<label for="' + text_key + '" class="col-sm-2 control-label">Text</label>',
          '<div class="col-sm-6 field">',
          '<div id="' + text_key + '" class="st-text-block" contenteditable="true"></div>',
          '</div>',
        '</div>',
      '</div>',
      '<div class="col-sm-3">',
        '<label for"' + title_key + '">',
          '<input name="' + title_key + '" type="hidden" value="false" />',
          '<input name="' + title_key + '" id="' + title_key + '" type="checkbox" value="true" />',
          'Display title',
        '</label>',
        '<div class="text-align">',
          '<p>Display text on:</p>',
          '<input type="radio" name="' + align_key + '" id="' + align_key + '-right" value="right" checked="true">',
          '<label for="' + align_key + '-right">Left</label>',
          '<input type="radio" name="' + align_key + '" id="' + align_key + '-left" value="left">',
          '<label for="' + align_key + '-left">Right</label>',
        '</div>',
      '</div>',
      '<div class="clearFix"></div>',
    '</div>'
  ].join("\n"));

  return SirTrevor.Block.extend({

    type: type,

    title: function() { return "Item + Text"; },

    editorHTML: function() {
      return template(this);
    },

    icon_name: type,

    toData: function() {
      var data = {};
      data[id_key] = this.$('#' + id_key).val();
      data[id_text_key] = this.$('#' + id_text_key).val();
      data[title_key] = this.$('#' + title_key).is(':checked');

      if (this.hasTextBlock()) {
        var content = this.getTextBlock().html();
        if (content.length > 0) {
          data.text = SirTrevor.toMarkdown(content, this.type);
        }else{
          data.text = "";
        }
      }

      data[align_key] = this.$('[name=' + align_key + ']:checked').val();
      this.setData(data);
    },

    onBlockRender: function() {
      addAutocompletetoSirTrevorForm();
      $('#' + id_text_key).focus();
    },

    loadData: function(data){
      this.getTextBlock().html(SirTrevor.toHTML(data.text, this.type));
      this.$('#' + id_text_key).val(data[id_text_key]);
      this.$('#' + id_key).val(data[id_key]);
      this.$('#' + title_key).prop('checked', data[title_key]);
      this.$('#' + align_key + "-" + data[align_key]).prop("checked", true);
    }
  });
})();