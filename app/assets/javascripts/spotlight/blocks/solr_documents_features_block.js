//= require spotlight/blocks/solr_documents_block

SirTrevor.Blocks.SolrDocumentsFeatures = (function(){

  return SirTrevor.Blocks.SolrDocuments.extend({
    textable: false,
    type: "solr_documents_features",
    title: function() { return "Item Features"; },

    icon_name: "item_features",
    blockGroup: 'Exhibit item widgets',
    description: "This widget displays items in features",
  });

})();