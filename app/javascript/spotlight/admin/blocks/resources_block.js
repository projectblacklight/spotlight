import Core from 'spotlight/core'
import SpotlightNestable from 'spotlight/admin/spotlight_nestable'

Core.Block.Resources = (function(){

  return Core.Block.extend({
    type: "resources",
    formable: true,
    autocompleteable: true,
    show_heading: true,
    show_alt_text: true,

    title: function() { return i18n.t("blocks:" + this.type + ":title"); },
    description: function() { return i18n.t("blocks:" + this.type + ":description"); },

    icon_name: "resources",
    blockGroup: function() { return i18n.t("blocks:group:items") },

    primary_field_key: "primary-caption-field",
    show_primary_field_key: "show-primary-caption",
    secondary_field_key: "secondary-caption-field",
    show_secondary_field_key: "show-secondary-caption",

    display_checkbox: "display-checkbox",
    decorative_checkbox: "decorative-checkbox",
    alt_text_textarea: "alt-text-textarea",

    globalIndex: 0,

    _itemPanelIiifFields: function(index, data) {
      return [];
    },

    _altTextFieldsHTML: function(index, data) {
      if (this.show_alt_text) {
        return this.altTextHTML(index, data);
      }
      return "";
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
          <li class="field form-inline dd-item dd3-item" data-resource-id="${resource_id}" data-id="${index}" id="${this.formId("item_" + data.id)}">
            <input type="hidden" name="item[${index}][id]" value="${resource_id}" />
            <input type="hidden" name="item[${index}][title]" value="${data.title}" />
            ${this._itemPanelIiifFields(index, data)}
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
              <div class="card d-flex dd3-content">
                <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
                <div class="card-header item-grid">
                  <div class="d-flex">
                    <div class="checkbox">
                      <input name="item[${index}][display]" type="hidden" value="false" />
                      <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + data.id)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                      <label class="sr-only visually-hidden" for="${this.formId(this.display_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:panel:display")}</label>
                    </div>
                    <div class="pic">
                      <img class="img-thumbnail" src="${(data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg")))}" />
                    </div>
                    <div class="main">
                      <div class="title card-title">${data.title}</div>
                      <div>${(data.slug || data.id)}</div>
                      ${this._altTextFieldsHTML(index, data)}
                    </div>
                    <div class="remove float-right float-end">
                      <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                    </div>
                  </div>
                  <div data-panel-image-pagination="true"></div>
                </div>
              </div>
            </li>
      `

      const panel = $(markup);
      var context = this;

      $('.remove a', panel).on('click', function(e) {
        e.preventDefault();
        $(this).closest('.field').remove();
        context.afterPanelDelete();

      });

      this.afterPanelRender(data, panel);

      return panel;
    },

    afterPanelRender: function(data, panel) {

    },

    afterPanelDelete: function() {

    },

    createItemPanel: function(data) {
      var panel = this._itemPanel(data);
      this.attachAltTextHandlers(panel);
      $(panel).appendTo($('.panels > ol', this.inner));
      $('[data-behavior="nestable"]', this.inner).trigger('change');
    },

    item_options: function() { return ""; },

    content: function() {
      var templates = [this.items_selector()];
      if (this.plustextable) {
        templates.push(this.text_area());
      }
      return templates.join("<hr />\n");
    },

    items_selector: function() { return [
    '<div class="row">',
      '<div class="col-md-8">',
        '<div class="form-group mb-3">',
        '<div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1"><ol class="dd-list"></ol></div>',
          this.autocomplete_control(),
        '</div>',
      '</div>',
      '<div class="col-md-4">',
        this.item_options(),
      '</div>',
    '</div>'].join("\n")
    },

    editorHTML: function() {
      return `<div class="form resources-admin clearfix">
        <div class="widget-header">
          ${this.description()}
        </div>
        ${this.content()}
      </div>`
    },

    _altTextData: function(data) {
      const isDecorative = data.decorative;
      const altText = isDecorative ? '' : (data.alt_text || '');
      const altTextBackup = data.alt_text_backup || '';
      const placeholderAttr = isDecorative ? '' : `placeholder="${i18n.t("blocks:resources:alt_text:placeholder")}"`;
      const disabledAttr = isDecorative ? 'disabled' : '';

      return { isDecorative, altText, altTextBackup, placeholderAttr, disabledAttr };
    },

    altTextHTML: function(index, data) {
      const { isDecorative, altText, altTextBackup, placeholderAttr, disabledAttr } = this._altTextData(data);
      return `<div class="mt-2 pt-2 d-flex">
          <div class="me-2 mr-2">
            <label class="col-form-label pb-0 pt-1" for="${this.formId(this.alt_text_textarea + '_' + data.id)}">${i18n.t("blocks:resources:alt_text:alternative_text")}</label>
            <div class="form-check mb-1 justify-content-end">
              <input class="form-check-input" type="checkbox" 
                id="${this.formId(this.decorative_checkbox + '_' + data.id)}" name="item[${index}][decorative]" ${isDecorative ? 'checked' : ''}>
              <label class="form-check-label" for="${this.formId(this.decorative_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:alt_text:decorative")}</label>
            </div>
          </div>
          <div class="flex-grow-1 flex-fill d-flex">
            <input type="hidden" name="item[${index}][alt_text_backup]" value="${altTextBackup}" />
            <textarea class="form-control w-100" rows="2" ${placeholderAttr}
              id="${this.formId(this.alt_text_textarea + '_' + data.id)}" name="item[${index}][alt_text]" ${disabledAttr}>${altText}</textarea>
          </div>
        </div>`
    },

    attachAltTextHandlers: function(panel) {
      if (this.show_alt_text) {
        const decorativeCheckbox = $('input[name$="[decorative]"]', panel);
        const altTextInput = $('textarea[name$="[alt_text]"]', panel);
        const altTextBackupInput = $('input[name$="[alt_text_backup]"]', panel);

        decorativeCheckbox.on('change', function() {
          const isDecorative = this.checked;
          if (isDecorative) {
            altTextBackupInput.val(altTextInput.val());
            altTextInput.val('');
          } else {
            altTextInput.val(altTextBackupInput.val());
          }
          altTextInput
            .prop('disabled', isDecorative)
            .attr('placeholder', isDecorative ? '' : i18n.t("blocks:resources:alt_text:placeholder"));
        });

        altTextInput.on('input', function() {
          $(this).data('lastValue', $(this).val());
        });
      }
    },

    onBlockRender: function() {
      SpotlightNestable.init($('[data-behavior="nestable"]', this.inner));

      $('[data-input-select-target]', this.inner).selectRelatedInput();
    },

    afterLoadData: function(data) {
      var context = this;
      $.each(Object.keys(data.item || {}).map(function(k) { return data.item[k]}).sort(function(a,b) { return a.weight - b.weight; }), function(index, item) {
        context.createItemPanel(item);
      });
    },
  });

})();
