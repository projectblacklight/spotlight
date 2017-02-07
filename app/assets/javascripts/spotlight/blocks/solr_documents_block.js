//= require spotlight/blocks/solr_documents_base_block

SirTrevor.Blocks.SolrDocuments = (function(){

  return SirTrevor.Blocks.SolrDocumentsBase.extend({
    type: "solr_documents",

    icon_name: "items",

    item_options: function() { return this.caption_options() + this.zpr_option(); },

    zpr_option: function() {
      return [
        '<div>',
        '<input name="<%= zpr_key %>" type="hidden" value="false" />',
        '<input name="<%= zpr_key %>" id="<%= formId(zpr_key) %>" data-key="<%= zpr_key %>" type="checkbox" value="true" />',
        '<label for="<%= formId(zpr_key) %>"><%= i18n.t("blocks:solr_documents:zpr:title") %></label>',
        '</div>'
      ].join("\n");
    },

    zpr_key: 'zpr_link'
  });

})();
