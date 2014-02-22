/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.Oembed =  (function(){

  var id_key = "url";
  var text_key = "item-text"
  var align_key = "text-align"

  var type = "oembed";

  var template = _.template([
    '<div class="form-horizontal oembed-text-admin clearfix">',
      '<div class="widget-header">',
        'This widget embeds a web resource and a text block to the left or right of it.',
      '</div>',
      '<div class="col-sm-9">',
        '<div class="form-group">',
          '<label for="' + id_key + '" class="col-sm-2 control-label">URL</label>',
          '<div class="col-sm-6 field">',
            '<input name="' + id_key + '"',
            ' class="st-input-string form-control ' + type + '" type="text" id="' + id_key + '" />',
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
        '<div class="text-align">',
          '<p>Display text on:</p>',
          '<input type="radio" name="' + align_key + '" id="' + align_key + '-right" value="right" checked="true">',
          '<label for="' + align_key + '-right">Left</label>',
          '<input type="radio" name="' + align_key + '" id="' + align_key + '-left" value="left">',
          '<label for="' + align_key + '-left">Right</label>',
        '</div>',
      '</div>',
    '</div>'
  ].join("\n"));

  return SirTrevor.Block.extend({

    type: type,

    title: function() { return "Embed + Text"; },

    editorHTML: function() {
      return template(this);
    },

    icon_name: type,

    toData: function() {
      var data = {};
      data[id_key] = this.$('#' + id_key).val();

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
    },

    loadData: function(data){
      this.getTextBlock().html(SirTrevor.toHTML(data.text, this.type));
      this.$('#' + id_key).val(data[id_key]);
      this.$('#' + align_key + "-" + data[align_key]).prop("checked", true);
    }
  });
})();