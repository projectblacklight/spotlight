//= require spotlight/blocks/solr_documents_block

SirTrevor.Blocks.SolrDocumentsEmbed = (function(){

  return SirTrevor.Blocks.SolrDocuments.extend({
    type: "solr_documents_embed",
    title: function() { return "Item Embed"; },

    icon_name: "item_embed",
    blockGroup: 'Exhibit item widgets',
    description: "This widget embeds items in the page",

    item_options: function() { return "" }
  });

})();