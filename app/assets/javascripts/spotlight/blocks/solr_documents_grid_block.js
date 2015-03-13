//= require spotlight/blocks/solr_documents_block

SirTrevor.Blocks.SolrDocumentsGrid = (function(){

  return SirTrevor.Blocks.SolrDocuments.extend({
    type: "solr_documents_grid",

    icon_name: "item_grid",


    item_options: function() { return "" }
  });

})();