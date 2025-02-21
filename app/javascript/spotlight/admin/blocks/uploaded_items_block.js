import SpotlightNestable from 'spotlight/admin/spotlight_nestable'
import Core from 'spotlight/core'

SirTrevor.Blocks.UploadedItems = (function(){
  return Core.Block.Resources.extend({
    plustextable: true,
    uploadable: true,
    autocompleteable: false,
    show_image_selection: false,
    
    id_key: 'file',

    type: 'uploaded_items',

    icon_name: 'items',

    blockGroup: 'undefined',

    // Clear out the default Uploadable upload options
    // since we will be using our own custom controls
    upload_options: { html: '' },

    fileInput: function() { return $(this.inner).find('input[type="file"]'); },

    onBlockRender: function(){
      SpotlightNestable.init($(this.inner).find('[data-behavior="nestable"]'));

      this.fileInput().on('change', (function(ev) {
        this.onDrop(ev.currentTarget);
      }).bind(this));
    },

    onDrop: function(transferData){
      var file = transferData.files[0],
          urlAPI = (typeof URL !== "undefined") ? URL : (typeof webkitURL !== "undefined") ? webkitURL : null;

      // Handle one upload at a time
      if (/image/.test(file.type)) {
        this.loading();

        this.uploader(
          file,
          function(data) {
            this.createItemPanel(data);
            this.fileInput().val('');
            this.ready();
          },
          function(error) {
            this.addMessage(i18n.t('blocks:image:upload_error'));
            this.ready();
          }
        );
      }
    },

    title: function() { return i18n.t('blocks:uploaded_items:title'); },
    description: function() { return i18n.t('blocks:uploaded_items:description'); },

    globalIndex: 0,

    _itemPanel: function(data) {
      var index = "file_" + this.globalIndex++;
      var checked = 'checked="checked"';

      if (data.display == 'false') {
        checked = '';
      }

      var dataId = data.id || data.uid;
      var dataTitle = data.title || data.name;
      var dataUrl = data.url || data.file.url;

      var markup = `
          <li class="field dd-item dd3-item" data-id="${index}" id="${this.formId(index)}">
            <input type="hidden" name="item[${index}][id]" value="${dataId}" />
            <input type="hidden" name="item[${index}][title]" value="${dataTitle}" />
            <input type="hidden" name="item[${index}][url]" data-item-grid-thumbnail="true"  value="${dataUrl}"/>
            <input data-property="weight" type="hidden" name="item[${index}][weight]" value="${data.weight}" />
            <div class="card d-flex dd3-content">
              <div class="dd-handle dd3-handle">${i18n.t("blocks:resources:panel:drag")}</div>
              <div class="card-header d-flex item-grid">
                <div class="checkbox">
                  <input name="item[${index}][display]" type="hidden" value="false" />
                  <input name="item[${index}][display]" id="${this.formId(this.display_checkbox + '_' + dataId)}" type="checkbox" ${checked} class="item-grid-checkbox" value="true"  />
                  <label class="visually-hidden" for="${this.formId(this.display_checkbox + '_' + dataId)}">${i18n.t("blocks:resources:panel:display")}</label>
                </div>
                <div class="pic">
                  <img class="img-thumbnail" src="${dataUrl}" />
                </div>
                <div class="main form-horizontal">
                  <div class="title card-title">${dataTitle}</div>
                  <div class="field row me-3">
                    <label for="${this.formId('caption_' + dataId)}" class="col-form-label col-md-3">${i18n.t("blocks:uploaded_items:caption")}</label>
                    <input type="text" class="form-control col" id="${this.formId('caption_' + dataId)}" name="item[${index}][caption]" data-field="caption"/>
                  </div>
                  <div class="field row me-3">
                    <label for="${this.formId('link_' + dataId)}" class="col-form-label col-md-3">${i18n.t("blocks:uploaded_items:link")}</label>
                    <input type="text" class="form-control col" id="${this.formId('link_' + dataId)}" name="item[${index}][link]" data-field="link"/>
                  </div>
                  ${this._altTextFieldsHTML(index, data)}
                </div>
                <div class="remove float-end">
                  <a data-item-grid-panel-remove="true" href="#">${i18n.t("blocks:resources:panel:remove")}</a>
                </div>
              </div>
            </li>`

      const panel = $(markup);
      panel.find('[data-field="caption"]').val(data.caption);
      panel.find('[data-field="link"]').val(data.link);
      var context = this;

      $('.remove a', panel).on('click', function(e) {
        e.preventDefault();
        $(this).closest('.field').remove();
        context.afterPanelDelete();
      });

      this.afterPanelRender(data, panel);

      return panel;
    },

    editorHTML: function() {
      return `<div class="form oembed-text-admin clearfix">
        <div class="widget-header">
          ${this.description()}
          ${this.alt_text_guidelines()}
          ${this.alt_text_guidelines_link()}
        </div>
        <div class="row">
          <div class="form-group mb-3 col-md-8">
            <div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">
              <ol class="dd-list">
              </ol>
            </div>
            <input type="file" id="uploaded_item_url" name="file[file_0][file_data]" />
          </div>
          <div class="col-md-4">
            <input name="${this.zpr_key}" type="hidden" value="false" />
            <input name="${this.zpr_key}" id="${this.formId(this.zpr_key)}" data-key="${this.zpr_key}" type="checkbox" value="true" />
            <label for="${this.formId(this.zpr_key)}">${i18n.t("blocks:solr_documents:zpr:title")}</label>
          </div>
        </div>
        ${this.text_area()}
      </div>`
    },

    altTextHTML: function(index, data) {
      const { isDecorative, altText, altTextBackup, placeholderAttr, disabledAttr } = this._altTextData(data);
      return `
      <div class="field row me-3">
        <div class="col-lg-3 ps-md-2">
          <label class="col-form-label text-nowrap pb-0 pt-1 justify-content-md-start justify-content-lg-end d-flex" for="${this.formId(this.alt_text_textarea + '_' + data.id)}">${i18n.t("blocks:resources:alt_text:alternative_text")}</label>
          <div class="form-check d-flex justify-content-md-start justify-content-lg-end">
            <input class="form-check-input" type="checkbox"
              id="${this.formId(this.decorative_checkbox + '_' + data.id)}" name="item[${index}][decorative]" ${isDecorative ? 'checked' : ''}>
            <label class="form-check-label" for="${this.formId(this.decorative_checkbox + '_' + data.id)}">${i18n.t("blocks:resources:alt_text:decorative")}</label>
          </div>
        </div>
        <input type="hidden" name="item[${index}][alt_text_backup]" value="${altTextBackup}" />
        <textarea class="col-lg-9" rows="2" ${placeholderAttr}
          id="${this.formId(this.alt_text_textarea + '_' + data.id)}" name="item[${index}][alt_text]" ${disabledAttr}>${altText}</textarea>
      </div>`
    },

    zpr_key: 'zpr_link'
  });
})();
