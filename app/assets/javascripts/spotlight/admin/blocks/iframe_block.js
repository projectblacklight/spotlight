/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.Iframe = (function(){

  return SirTrevor.Block.extend({
    type: "Iframe",
    formable: true,
    
    title: function() { return i18n.t('blocks:iframe:title'); },
    description: function() { return i18n.t('blocks:iframe:description'); },

    icon_name: "iframe",
    
    editorHTML: function() {
      return _.template(this.template, this)(this);
    },

    template: [
      '<div class="clearfix">',
        '<div class="widget-header">',
          '<%= description() %>',
        '</div>',
        '<textarea name="code" class="form-control" rows="5" placeholder="<%= i18n.t("blocks:iframe:placeholder") %>"></textarea>',
      '</div>'
    ].join("\n"),
  });
})();