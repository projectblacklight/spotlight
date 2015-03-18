//= require spotlight/blocks/solr_documents_block

SirTrevor.Blocks.SolrDocumentsEmbed = (function(){

  return SirTrevor.Blocks.SolrDocuments.extend({
    type: "solr_documents_embed",

    icon_name: "item_embed",

    item_options: function() { return "" },

    afterPreviewLoad: function(options) {
      this.$el.find('picture[data-openseadragon]').openseadragon();
    }
  });

})();