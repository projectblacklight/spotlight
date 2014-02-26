/*
  Simple Image Block
*/

SirTrevor.Blocks.SearchResults =  (function(){

  var template = _.template([
    'Search Query Params:<input name="search" ',
    ' class="st-input-string st-required search" type="text" />'
  ].join("\n"));

  return Spotlight.Block.extend({

  type: "search_results",

  title: function() { return "Search Results"; },

  icon_name: 'search_results',

  loadData: function(data){
    this.$('.search').val(data.search);
  }
});
})();