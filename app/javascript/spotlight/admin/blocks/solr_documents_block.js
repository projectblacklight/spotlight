//= require spotlight/admin/blocks/solr_documents_base_block
import SirTrevor from 'sir-trevor'

SirTrevor.Blocks.SolrDocuments = (function(){

  return SirTrevor.Blocks.SolrDocumentsBase.extend({
    type: "solr_documents",

    icon_name: "items",

    item_options: function() { return this.caption_options() + this.zpr_option(); },

    zpr_option: function() {
      return `
        <div>
        <input name="${this.zpr_key}" type="hidden" value="false" />
        <input name="${this.zpr_key}" id="${this.formId(this.zpr_key)}" data-key="${this.zpr_key}" type="checkbox" value="true" />
        <label for="${this.formId(this.zpr_key)}">${i18n.t("blocks:solr_documents:zpr:title")}</label>
        </div>
      `
    },

    zpr_key: 'zpr_link'
  });

})();
