/*
  Sir Trevor BrowseGroupCategories
*/
import Core from 'spotlight/core'

SirTrevor.Blocks.BrowseGroupCategories = (function(){

  return Core.Block.Resources.extend({
    type: "browse_group_categories",
    icon_name: "browse",

    autocomplete_control: function() {
      const autocompleteID = this.blockID + '-autocomplete';
      return `<auto-complete src="${this.autocomplete_url()}" for="${autocompleteID}-popup" fetch-on-empty>
        <input type="text" name="${autocompleteID}" placeholder="${i18n.t("blocks:browse_group_categories:autocomplete")}" data-default-typeahead>
        <ul id="${autocompleteID}-popup"></ul>
        <div id="${autocompleteID}-popup-feedback" class="sr-only visually-hidden"></div>
      </auto-complete>`
    },
    autocomplete_template: function(obj) {
      return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">
      <span class="autocomplete-title">${this.highlight(obj.title)}</span><br/></div>`
    },

    autocomplete_url: function() {
      return document.getElementById(this.instanceID).closest('form[data-autocomplete-exhibit-browse-groups-path]').dataset.autocompleteExhibitBrowseGroupsPath;
    },
    autocomplete_fetch: function(url) {
      return this.fetchOnceAndFilterLocalResults(url);
    },
    _itemPanel: function(data) {
      var index = "item_" + this.globalIndex++;
      var checked;
      if (data.display == "true") {
        checked = "checked='checked'"
      } else {
        checked = "";
      }
      var resource_id = data.slug || data.id;
      var markup = `
        <li class="field dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId(index)}">
          <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
          <input type="hidden" name="item[${index}][title]" value="${data.title}" />
          <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
            <div class="card d-flex dd3-content">
              <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
              <div class="d-flex card-header item-grid justify-content-between">
                <div class="d-flex flex-grow-1">
                  <div class="checkbox">
                    <input name="item[${index}][display]" type="hidden" value="false" />
                    <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                    <label class="sr-only visually-hidden" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                  </div>
                  <div class="main">
                    <div class="title card-title">${data.title}</div>
                  </div>
                </div>
                <div class="d-flex">
                  <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                </div>
              </div>
            </div>
          </li>`

      const panel = $(markup);
      var context = this;

      $('a[data-item-grid-panel-remove]', panel).on('click', function(e) {
        e.preventDefault();
        $(this).closest('.field').remove();
        context.afterPanelDelete();

      });

      this.afterPanelRender(data, panel);

      return panel;
    },

    item_options: function() { return `
      <label>
        <input type="hidden" name="display-item-counts" value="false" />
        <input type="checkbox" name="display-item-counts" value="true" checked />
        ${i18n.t("blocks:browse_group_categories:item_counts")}
      </label>`
    },
  });
})();
