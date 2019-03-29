Spotlight.Block.Resources = (function(){

  return Spotlight.Block.extend({
    type: "resources",
    formable: true,
    autocompleteable: true,
    show_heading: true,

    title: function() { return i18n.t("blocks:" + this.type + ":title"); },
    description: function() { return i18n.t("blocks:" + this.type + ":description"); },

    icon_name: "resources",
    blockGroup: function() { return i18n.t("blocks:group:items") },

    primary_field_key: "primary-caption-field",
    show_primary_field_key: "show-primary-caption",
    secondary_field_key: "secondary-caption-field",
    show_secondary_field_key: "show-secondary-caption",

    display_checkbox: "display-checkbox",

    globalIndex: 0,

    _itemPanelIiifFields: function(index, data) {
      return [];
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
      var markup = [
          '<li class="field form-inline dd-item dd3-item" data-resource-id="' + resource_id + '" data-id="' + index + '" id="' + this.formId("item_" + data.id) + '">',
            '<input type="hidden" name="item[' + index + '][id]" value="' + resource_id + '" />',
            '<input type="hidden" name="item[' + index + '][title]" value="' + data.title + '" />',
            this._itemPanelIiifFields(index, data),
            '<input data-property="weight" type="hidden" name="item[' + index + '][weight]" value="' + data.weight + '" />',
            '<div class="dd-handle dd3-handle"><%= i18n.t("blocks:resources:panel:drag") %></div>',
              '<div class="dd3-content card">',
                '<div class="card-header item-grid">',
                  '<div class="checkbox">',
                    '<input name="item[' + index + '][display]" type="hidden" value="false" />',
                    '<input name="item[' + index + '][display]" id="'+ this.formId(this.display_checkbox + '_' + data.id) + '" type="checkbox" ' + checked + ' class="item-grid-checkbox" value="true"  />',
                    '<label class="sr-only" for="'+ this.formId(this.display_checkbox + '_' + data.id) +'"><%= i18n.t("blocks:resources:panel:display") %></label>',
                  '</div>',
                  '<div class="pic thumbnail">',
                    '<img src="' + (data.thumbnail_image_url || ((data.iiif_tilesource || "").replace("/info.json", "/full/!100,100/0/default.jpg"))) + '" />',
                  '</div>',
                  '<div class="main">',
                    '<div class="title card-title">' + data.title + '</div>',
                    '<div>' + (data.slug || data.id) + '</div>',
                  '</div>',
                  '<div class="remove float-right">',
                    '<a data-item-grid-panel-remove="true" href="#"><%= i18n.t("blocks:resources:panel:remove") %></a>',
                  '</div>',
                  '<div class="h5" data-panel-image-pagination="true"></div>',
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

    afterPanelRender: function(data, panel) {

    },

    afterPanelDelete: function() {

    },

    createItemPanel: function(data) {
      var panel = this._itemPanel(data);
      $(panel).appendTo($('.panels > ol', this.inner));
      $('[data-behavior="nestable"]', this.inner).trigger('change');
    },

    item_options: function() { return ""; },

    content: function() {
      var templates = [this.items_selector()];
      if (this.plustextable) {
        templates.push(this.text_area());
      }
      return _.template(templates.join("<hr />\n"))(this);
    },

    items_selector: function() { return [
    '<div class="row">',
      '<div class="col-md-8">',
        '<div class="form-group">',
        '<div class="panels dd nestable-item-grid" data-behavior="nestable" data-max-depth="1"><ol class="dd-list"></ol></div>',
          this.autocomplete_control(),
        '</div>',
      '</div>',
      '<div class="col-md-4">',
        this.item_options(),
      '</div>',
    '</div>'].join("\n")
    },

    template: [
      '<div class="form resources-admin clearfix">',
        '<div class="widget-header">',
          '<%= description() %>',
        '</div>',
        '<%= content() %>',
      '</div>'
    ].join("\n"),

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
