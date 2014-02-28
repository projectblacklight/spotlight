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
    title_key:"show-title",
    text_key:"item-text",
    align_key:"text-align",

    type: "item-text",

    title: function() { return "Item + Text"; },

    icon_name: "item-text",

    onBlockRender: function() {
      Spotlight.Block.prototype.onBlockRender.apply();
      $('#' + this.formId(this.id_text_key)).focus();
    },

    template: _.template([
    '<div class="form-horizontal item-text-admin">',
      '<div class="widget-header">',
        'This widget displays a thumbnail image of the repository item you selected and a text block to the left or right of it.',
      '</div>',
      '<div class="col-sm-9">',
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
      '<div class="col-sm-3">',
        '<label for="<%= formId(title_key) %>">',
          '<input name="<%= title_key %>" id="<%= formId(title_key) %>" type="checkbox" value="true" />',
          'Display title',
        '</label>',
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