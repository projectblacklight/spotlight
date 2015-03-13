//= require spotlight/blocks/solr_documents_block

SirTrevor.Blocks.SolrDocumentsGrid = (function(){

  return SirTrevor.Blocks.SolrDocuments.extend({
    type: "solr_documents_grid",
    title: function() { return "Item Grid"; },

    icon_name: "item_grid",
    blockGroup: 'Exhibit item widgets',
    description: "This widget displays exhibit items in a multi-row grid. Optionally, you can add a heading and/or text to be displayed adjacent to the items.",

    item_options: function() { return "" }
  });

})();