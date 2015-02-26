/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.Rule = (function(){

  return Spotlight.Block.extend({
    type: "rule",

    title: function() { return "Horizontal Rule"; },

    icon_name: "rule",

    template: '<hr />'
  });
})();