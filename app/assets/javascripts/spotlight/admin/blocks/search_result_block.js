//= require spotlight/admin/blocks/browse_block

SirTrevor.Blocks.SearchResults =  (function(){

  return SirTrevor.Blocks.Browse.extend({

    type: "search_results",

    icon_name: 'search_results',

    searches_key: "slug",
    view_key: "view",
    plustextable: false,

    content: function() {
      return this.items_selector()
    },

    item_options: function() {
      var block = this;
      var fields = $('[data-blacklight-configuration-search-views]').data('blacklight-configuration-search-views');

      return $.map(fields, function(field) {
        checkbox = ""
        checkbox += "<div>";
        checkbox += "<label for='" + block.formId(block.view_key + field.key) + "'>";
          checkbox += "<input id='" + block.formId(block.view_key + field.key) + "' name='" + block.view_key + "[]' type='checkbox' value='" + field.key + "' /> ";
            checkbox += field.label;
            checkbox += "</label>";
          checkbox += "</div>";
        return checkbox;
      }).join("\n");
    },

    afterPanelRender: function(data, panel) {
      $(this.inner).find('.item-input-field').attr("disabled", "disabled");
    },

    afterPanelDelete: function() {
      $(this.inner).find('.item-input-field').removeAttr("disabled");
    },

  });
})();
