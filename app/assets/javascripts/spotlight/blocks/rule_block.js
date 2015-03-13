/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.Rule = (function(){

  return SirTrevor.Block.extend({
    type: "rule",
    
    title: function() { return i18n.t('blocks:rule:title'); },

    icon_name: "rule",

    previewable: false,
    
    editorHTML: function() {
      return _.template(this.template, this)(this);
    },

    template: '<hr />'
  });
})();