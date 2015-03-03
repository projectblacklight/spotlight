//= require 'spotlight/blocks/multi_up_item_grid.js'
SirTrevor.Blocks.ItemGrid =  (function(){

  return SirTrevor.Blocks.MultiUpItemGrid.extend({

    type: "item-grid",

    title: function() { return "Item Grid"; },

    icon_name: "item-grid",

    description: "This widget displays one to seven thumbnails of items in a grid.",

    inputFieldsCount: 7,

    text_key:"item-text",
    heading_key: "title",
    align_key:"text-align",
    
    template: [
    '<div class="form-horizontal <%= key %>-admin clearfix">',
      '<div class="widget-header">',
        '<%= description %>',
      '</div>',
      '<div class="col-sm-8">',
        '<label for="<%= formId(id_key) %>_0" class="control-label">Selected items to display</label>',
        '<div class="form-inline form-group panel-group dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">',
          '<ol class="dd-list">',
            '<%= buildInputFields(inputFieldsCount) %>',
          '</ol>',
        '</div>',
        '<div class="form-group">',
          '<div class="field">',
            '<label for="<%= formId(heading_key) %>" class="control-label">Heading</label>',
            '<input type="text" class="form-control" id="<%= formId(heading_key) %>" name="<%= heading_key %>" />',
          '</div>',
          '<div class="field">',
            '<label for="<%= formId(text_key) %>" class="control-label">Text</label>',
            '<div id="<%= formId(text_key) %>" class="st-text-block form-control" contenteditable="true"></div>',
          '</div>',
        '</div>',
      '</div>',
      '<div class="col-sm-4">',
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
})();;