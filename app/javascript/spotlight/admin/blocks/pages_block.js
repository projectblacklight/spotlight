import Core from 'spotlight/core'

SirTrevor.Blocks.FeaturedPages = (function(){

  return Core.Block.Resources.extend({
    type: "featured_pages",

    icon_name: "pages",

    show_image_selection: false,

    autocomplete_url: function() { return document.getElementById(this.instanceID).closest('form[data-autocomplete-exhibit-pages-path]').dataset.autocompleteExhibitPagesPath; },
    autocomplete_fetch: function(url) {
      return this.fetchOnceAndFilterLocalResults(url);
    },
    autocomplete_template: function(obj) {
      const description = obj.description ? `<small>&nbsp;&nbsp;${obj.description}</small>` : '';
      const thumbnail = obj.thumbnail_image_url ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>` : ''
      return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/>${description}</div>`
    },
  });

})();
