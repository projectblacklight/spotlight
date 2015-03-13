//= require spotlight/blocks/resources_block

SirTrevor.Blocks.Browse = (function(){

  return Spotlight.Block.Resources.extend({
    type: "browse",

    icon_name: "pages",

    autocomplete_url: function() { return this.$el.closest('form[data-autocomplete-exhibit-searches-path]').data('autocomplete-exhibit-searches-path').replace("%25QUERY", "%QUERY"); },
    autocomplete_template: function() { return '<div class="autocomplete-item{{#unless published}} blacklight-private{{/unless}}">{{#if thumbnail_image_url}}<div class="document-thumbnail thumbnail"><img src="{{thumbnail_image_url}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' },

    item_options: function() { return [
      '<label>',
        '<input type="checkbox" name="display-item-counts" value="true" checked />',
        '<%= i18n.t("blocks:browse:item_counts") %>',
      '</label>'
    ].join("\n") },
  });

})();
