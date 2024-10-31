//= require spotlight/admin/blocks/solr_documents_base_block

SirTrevor.Blocks.SolrDocumentsGrid = (function(){

  return SirTrevor.Blocks.SolrDocumentsBase.extend({
    type: "solr_documents_grid",

    icon_name: "item_grid",


    item_options: function() { return "" }
  });

})();
