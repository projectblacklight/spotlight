SirTrevor.Blocks.UploadedItems = (function(){
  return Spotlight.Block.Resources.extend({
    textable: true,
    uploadable: true,
    autocompleteable: false,

    id_key: 'file',

    type: 'uploaded_items',

    icon_name: 'items',

    blockGroup: 'undefined',

    // Clear out the default Uploadable upload options
    // since we will be using our own custom controls
    upload_options: { html: '' },

    fileInput: function() { return this.$el.find('input[type="file"]'); },

    onBlockRender: function(){
      SpotlightNestable.init(this.$el.find('[data-behavior="nestable"]'));

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

      var markup = [
          '<li class="field form-inline dd-item dd3-item" data-id="' + index + '" id="' + this.formId("item_" + dataId) + '">',
            '<input type="hidden" name="item[' + index + '][id]" value="' + dataId + '" />',
            '<input type="hidden" name="item[' + index + '][title]" value="' + dataTitle + '" />',
            '<input type="hidden" name="item[' + index + '][url]" data-item-grid-thumbnail="true"  value="' + dataUrl + '"/>',
            '<input data-property="weight" type="hidden" name="item[' + index + '][weight]" value="' + data.weight + '" />',
            '<div class="dd-handle dd3-handle"><%= i18n.t("blocks:resources:panel:drag") %></div>',
              '<div class="dd3-content panel panel-default">',
                '<div class="panel-heading item-grid">',
                  '<div class="checkbox">',
                    '<input name="item[' + index + '][display]" type="hidden" value="false" />',
                    '<input name="item[' + index + '][display]" id="'+ this.formId(this.display_checkbox + '_' + dataId) + '" type="checkbox" ' + checked + ' class="item-grid-checkbox" value="true"  />',
                    '<label class="sr-only" for="'+ this.formId(this.display_checkbox + '_' + dataId) +'"><%= i18n.t("blocks:resources:panel:display") %></label>',
                  '</div>',
                  '<div class="pic thumbnail">',
                    '<img src="' + dataUrl + '" />',
                  '</div>',
                  '<div class="main">',
                    '<div class="title panel-title">' + dataTitle + '</div>',
                  '</div>',
                  '<div class="remove pull-right">',
                    '<a data-item-grid-panel-remove="true" href="#"><%= i18n.t("blocks:resources:panel:remove") %></a>',
                  '</div>',
                '</div>',
              '</div>',
            '</li>'
      ].join("\n");

      var panel = $(_.template(markup)(this));
      var context = this;

      $('.remove a', panel).on('click', function(e) {
        e.preventDefault();
        $(this).closest('.field').remove();
        context.afterPanelDelete();
      });

      this.afterPanelRender(data, panel);

      return panel;
    },

    template: [
      '<div class="form oembed-text-admin clearfix">',
        '<div class="widget-header">',
          '<%= description() %>',
        '</div>',
        '<div class="row">',
          '<div class="form-group col-md-8">',
            '<div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">',
              '<ol class="dd-list">',
              '</ol>',
            '</div>',
            '<input type="file" id="uploaded_item_url" name="file[file_0][file_data]" />',
          '</div>',
        '</div>',
        '<%= text_area() %>',
      '</div>'
    ].join("\n")
  });
})();
