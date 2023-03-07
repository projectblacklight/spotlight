/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/
import Core from 'spotlight/core'

SirTrevor.Blocks.Oembed =  (function(){

  return Core.Block.extend({
    plustextable: true,

    id_key:"url",

    type: "oembed",
    
    title: function() { return i18n.t('blocks:oembed:title'); },
    description: function() { return i18n.t('blocks:oembed:description'); },

    icon_name: "oembed",
    show_heading: false,

    editorHTML: function () {
      return `<div class="form oembed-text-admin clearfix">
      <div class="widget-header">
        ${this.description()}
      </div>
      <div class="row">
        <div class="form-group col-md-8">
          <label for="${this.formId(id_key)}">${i18n.t("blocks:oembed:url")}</label>
          <input name="${id_key}" class="form-control col-md-6" type="text" id="${this.formId(id_key)}" />
        </div>
      </div>
      ${this.text_area()}
    </div>`
    }
  });
})();