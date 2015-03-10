//= require spotlight/blocks/resources_block

SirTrevor.Blocks.FeaturedPages = (function(){

  return Spotlight.Block.Resources.extend({
    type: "featured_pages",

    title: function() { return "Highlight Feature Pages"; },

    icon_name: "pages",
    blockGroup: 'Exhibit item widgets',
    description: "This widget displays pages",

    autocomplete_url: function() { return this.$el.closest('form[data-autocomplete-exhibit-feature-pages-path]').data('autocomplete-exhibit-feature-pages-path').replace("%25QUERY", "%QUERY"); },
    autocomplete_template: function() { return '<div class="autocomplete-item{{#unless published}} blacklight-private{{/unless}}">{{log "Look at me"}}{{log thumbnail_image_url}}{{#if thumbnail_image_url}}<div class="document-thumbnail thumbnail"><img src="{{thumbnail_image_url}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' },
  });

})();
