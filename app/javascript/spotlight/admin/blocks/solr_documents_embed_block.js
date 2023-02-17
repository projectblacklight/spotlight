//= require spotlight/admin/blocks/solr_documents_base_block

SirTrevor.Blocks.SolrDocumentsEmbed = (function(){

  return SirTrevor.Blocks.SolrDocumentsBase.extend({
    type: "solr_documents_embed",

    icon_name: "item_embed",

    item_options: function() { return "" },

    afterPreviewLoad: function(options) {
      $(this.inner).find('picture[data-openseadragon]').openseadragon();
    }
  });

})();
