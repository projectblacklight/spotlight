import Core from 'spotlight/core'

SirTrevor.Blocks.Browse = (function(){

  return Core.Block.Resources.extend({
    type: "browse",

    icon_name: "browse",

    autocomplete_url: function() {
      return document.getElementById(this.instanceID).closest('form[data-autocomplete-exhibit-searches-path]').dataset.autocompleteExhibitSearchesPath;
    },

    autocomplete_fetch: function(url) {
      return this.fetchOnceAndFilterLocalResults(url);
    },

    autocomplete_template: function(obj) {
      const thumbnail = obj.thumbnail_image_url ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail_image_url}" /></div>` : ''
      const description = obj.description ? `<small>&nbsp;&nbsp;${obj.description}</small>` : '';
      return `<div class="autocomplete-item${!obj.published ? ' blacklight-private' : ''}">${thumbnail}
      <span class="autocomplete-title">${this.highlight(obj.full_title)}</span>${description}</div>`;
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
            <input type="hidden" name="item[${index}][full_title]" value="${(data.full_title || data.title)}" />
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
              <div class="card d-flex dd3-content">
                <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
                <div class="card-header item-grid">
                  <div class="d-flex">
                    <div class="checkbox">
                      <input name="item[${index}][display]" type="hidden" value="false" />
                      <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                      <label class="visually-hidden" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                    </div>
                    <div class="pic">
                      <img class="img-thumbnail" src="${(data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")))}" />
                    </div>
                    <div class="main">
                      <div class="title card-title">${(data.full_title || data.title)}</div>
                      <div>${(data.slug || data.id)}</div>
                    </div>
                    <div class="remove float-end">
                      <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                    </div>
                  </div>
                </div>
              </div>
            </li>`

      var panel = $(markup);
      var context = this;

      $('.remove a', panel).on('click', function(e) {
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
        ${i18n.t("blocks:browse:item_counts")}
      </label>`
    },
  });

})();
