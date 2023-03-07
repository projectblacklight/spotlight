import Core from 'spotlight/core'

SirTrevor.Blocks.FeaturedPages = (function(){

  return Core.Block.Resources.extend({
    type: "featured_pages",

    icon_name: "pages",

    autocomplete_url: function() { return $(this.inner).closest('form[data-autocomplete-exhibit-pages-path]').data('autocomplete-exhibit-pages-path').replace("%25QUERY", "%QUERY"); },
    autocomplete_template: function(obj) {
      const thumbnail = obj.thumbnail_image_url ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>` : ''
      return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${obj.title}</span><br/><small>&nbsp;&nbsp;${obj.description}</small></div>`
    },
    bloodhoundOptions: function() {
      return {
        prefetch: {
          url: this.autocomplete_url(),
          ttl: 0
        }
      };
    }
  });

})();
