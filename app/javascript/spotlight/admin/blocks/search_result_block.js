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
      var element = document.querySelector('[data-blacklight-configuration-search-views]');
      var fieldsData = element ? element.dataset.blacklightConfigurationSearchViews : null;
      var fields = [];
      if (fieldsData) {
        try {
          fields = JSON.parse(fieldsData);
        } catch (e) {
          // ignore parse errors
        }
      }

      return fields.map(function(field) {
        return `<div>
          <label for='${block.formId(block.view_key + field.key)}'>
            <input id='${block.formId(block.view_key + field.key)}' name='${block.view_key}[]' type='checkbox' value='${field.key}' />
          ${field.label}
          </label>
        </div>`
      }).join("\n");
    },

    afterPanelRender: function(data, panel) {
      this.inner.querySelectorAll('.item-input-field').forEach(function(el) {
        el.disabled = true;
      });
    },

    afterPanelDelete: function() {
      this.inner.querySelectorAll('.item-input-field').forEach(function(el) {
        el.disabled = false;
      });
    },

  });
})();
