import Spotlight from 'spotlight'

SirTrevor.Blocks.FeaturedPages = (function(){

  return Spotlight.Block.Resources.extend({
    type: "featured_pages",

    icon_name: "pages",

    autocomplete_url: function() { return $(this.inner).closest('form[data-autocomplete-exhibit-pages-path]').data('autocomplete-exhibit-pages-path').replace("%25QUERY", "%QUERY"); },
    autocomplete_template: function() { return '<div class="autocomplete-item{{#unless published}} blacklight-private{{/unless}}">{{#if thumbnail_image_url}}<div class="document-thumbnail"><img class="img-thumbnail" src="{{thumbnail_image_url}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' },
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
