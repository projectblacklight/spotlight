/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/
import SirTrevor from 'sir-trevor'

SirTrevor.Blocks.Rule = (function(){

  return SirTrevor.Block.extend({
    type: "rule",
    
    title: function() { return i18n.t('blocks:rule:title'); },

    icon_name: "rule",
    
    editorHTML: function() {
      return '<hr />'
    }
  });
})();