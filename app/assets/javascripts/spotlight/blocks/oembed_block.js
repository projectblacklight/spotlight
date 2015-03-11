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
    textable: true,

    id_key:"url",

    type: "oembed",

    title: function() { return "Embed + Text"; },

    icon_name: "oembed",
    show_heading: false,

    template: [
    '<div class="form oembed-text-admin clearfix">',
      '<div class="widget-header">',
        'This widget embeds a web resource and a text block to the left or right of it.',
      '</div>',
      '<div class="row">',
        '<div class="form-group col-md-8">',
          '<label for="<%= formId(id_key) %>">URL</label>',
          '<input name="<%= id_key %>" class="form-control col-md-6" type="text" id="<%= formId(id_key) %>" />',
        '</div>',
      '</div>',
      '<%= text_area() %>',
    '</div>'
  ].join("\n")
  });
})();