//= require spotlight/blocks/solr_documents_block

SirTrevor.Blocks.SolrDocumentsGrid = (function(){

  return SirTrevor.Blocks.SolrDocuments.extend({
    type: "solr_documents_grid",
    title: function() { return "Item Grid"; },

    icon_name: "item_grid",
    blockGroup: 'Exhibit item widgets',
    description: "This widget displays items in grids",

    item_options: function() { return "" }
  });

})();