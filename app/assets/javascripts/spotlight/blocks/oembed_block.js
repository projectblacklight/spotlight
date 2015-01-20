/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.Oembed =  (function(){

  return Spotlight.Block.extend({

    id_key:"url",
    text_key:"item-text",
    align_key:"text-align",

    type: "oembed",

    title: function() { return "Embed + Text"; },

    icon_name: "oembed",

    template: [
    '<div class="form-horizontal oembed-text-admin clearfix">',
      '<div class="widget-header">',
        'This widget embeds a web resource and a text block to the left or right of it.',
      '</div>',
      '<div class="col-sm-9">',
        '<div class="form-group">',
          '<label for="<%= formId(id_key) %>" class="col-sm-2 control-label">URL</label>',
          '<div class="col-sm-6 field">',
            '<input name="<%= id_key %>" class="st-input-string form-control <%= type %>" type="text" id="<%= formId(id_key) %>" />',
          '</div>',
        '</div>',
        '<div class="form-group">',
          '<label for="<%= formId(text_key) %>" class="col-sm-2 control-label">Text</label>',
          '<div class="col-sm-6 field">',
          '<div id="<%= formId(text_key) %>" class="st-text-block" contenteditable="true"></div>',
          '</div>',
        '</div>',
      '</div>',
      '<div class="col-sm-3">',
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
  ].join("\n")
  });
})();