/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/
import SirTrevor from 'sir-trevor'

SirTrevor.Blocks.Iframe = (function(){

  return SirTrevor.Block.extend({
    type: "Iframe",
    formable: true,
    
    title: function() { return i18n.t('blocks:iframe:title'); },
    description: function() { return i18n.t('blocks:iframe:description'); },

    icon_name: "iframe",
    
    editorHTML: function() {
      return `<div class="clearfix">
        <div class="widget-header">
          ${this.description()}
        </div>
        <textarea name="code" class="form-control" rows="5" placeholder="${i18n.t("blocks:iframe:placeholder")}"></textarea>
      </div>`;
    }
  });
})();