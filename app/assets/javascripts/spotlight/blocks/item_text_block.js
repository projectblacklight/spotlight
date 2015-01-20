/*
  Sir Trevor ItemText Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title, 
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.ItemText =  (function(){

  return Spotlight.Block.extend({

    id_key:"item-id",
    id_text_key:"item-text-id",
    title_key: "spotlight_title_field",
    panel: "item-panel",
    primary_field_key: "item-grid-primary-caption-field",
    thumbnail_key: "item-thumbnail",
    show_primary_field_key: "show-primary-caption",
    secondary_field_key: "item-grid-secondary-caption-field",
    show_secondary_field_key: "show-secondary-caption",
    text_key:"item-text",
    align_key:"text-align",

    type: "item-text",

    blockGroup: 'Exhibit item widgets',

    title: function() { return "Item + Text"; },

    icon_name: "item-text",

    onBlockRender: function() {
      Spotlight.Block.prototype.onBlockRender.apply();
      $('#' + this.formId(this.id_text_key)).focus();
      this.loadCaptionField();
      this.addCaptionSelectFocus();
      addRemoveAutocompletedPanelBehavior();
    },

    afterLoadData: function(data){
      // set a data attribute on the select fields so the ajax request knows which option to select
      this.$('select#' + this.formId(this.primary_field_key)).data('select-after-ajax', data[this.primary_field_key]);
      this.$('select#' + this.formId(this.secondary_field_key)).data('select-after-ajax', data[this.secondary_field_key]);
      var context = this;
      $.ajax($('form[data-autocomplete-url]').data('autocomplete-url') + '?q=id:' + data[context.id_key])
        .success(function(ajaxData){
          var thumbnails   = ajaxData['docs'][0]['thumbnails'],
              privateLabel = ajaxData['docs'][0]['private'];
          context.$('[data-target-panel]').each(function(){
            if ($(this).prop("value") != "") {
              swapInputForPanel($(this), context.$($(this).data('target-panel')), {
                id: data[context.id_key],
                title: data[context.id_text_key],
                thumbnail: data[context.thumbnail_key + "_0"],
                thumbnails: thumbnails,
                private: privateLabel
              });
            }
          });
        });
    },

    template: [
    '<div class="form-horizontal item-text-admin">',
      '<div class="widget-header">',
        'This widget displays a thumbnail image of the repository item you selected and a text block to the left or right of it.',
      '</div>',
      '<div class="col-sm-8">',
        '<div class="form-group">',
          '<div class="col-sm-11 field">',
            '<label for="<%= formId(id_text_key) %>" class="control-label">Selected item</label>',
            '<li class="dd-item dd3-item" style="display:none" id="<%= formId(panel + "_0") %>">',
              '<div class="dd3-content panel panel-default">',
                '<div class="panel-heading item-grid">',
                  '<div class="pic thumbnail">',
                    '<img style="display:none" />',
                    '<input type="hidden" name="<%= thumbnail_key + "_0" %>" id="<%= formId(thumbnail_key + "_0") %>" data-item-grid-thumbnail="true" data-nestable-observe="true" />',
                  '</div>',
                  '<div class="main">',
                    '<div class="title panel-title" data-panel-title="true"></div>',
                    '<div data-panel-id-display="true"></div>',
                    '<div data-panel-image-pagination="true"></div>',
                  '</div>',
                  '<div class="remove pull-right">',
                    '<a data-item-grid-panel-remove="true" href="#">Remove</a>',
                  '</div>',
                '</div>',
              '</div>',
              '<input name="<%= id_key %>" type="hidden" id="<%= formId(id_key) %>" />',
            '</li>',
            '<input data-id_field="#<%= formId(id_key) %>" name="<%= id_text_key %>"',
            ' class="st-input-string form-control <%= type %>" type="text" id="<%= formId(id_text_key) %>" data-twitter-typeahead="true" data-target-panel="#<%= formId(panel + "_0") %>" />',
          '</div>',
        '</div>',
        '<div class="form-group">',
          '<div class="col-sm-11 field">',
            '<label for="<%= formId(text_key) %>" class="control-label">Text</label>',
            '<div id="<%= formId(text_key) %>" class="st-text-block" contenteditable="true"></div>',
          '</div>',
        '</div>',
      '</div>',
      '<div class="col-sm-4">',
        '<div class="field-select primary-caption" data-behavior="item-caption-admin">',
          '<input name="<%= show_primary_field_key %>" id="<%= formId(show_primary_field_key) %>" type="checkbox" value="true" />',
          '<label for="<%= formId(show_primary_field_key) %>">Primary caption</label>',
          '<select name="<%= primary_field_key %>" id="<%= formId(primary_field_key) %>">',
            '<option value="">Select...</option>',
            '<%= _.template(caption_field_template)({field: title_key, label: "Title", selected: ""}) %>',
          '</select>',
        '</div>',
        '<div class="field-select secondary-caption" data-behavior="item-caption-admin">',
          '<input name="<%= show_secondary_field_key %>" id="<%= formId(show_secondary_field_key) %>" type="checkbox" value="true" />',
          '<label for="<%= formId(show_secondary_field_key) %>">Secondary caption</label>',
          '<select name="<%= secondary_field_key %>" id="<%= formId(secondary_field_key) %>">',
            '<option value="">Select...</option>',
            '<%= _.template(caption_field_template)({field: title_key, label: "Title", selected: ""}) %>',
          '</select>',
        '</div>',
        '<div class="text-align">',
          '<p>Display text on:</p>',
          '<input data-key="<%= align_key %>" type="radio" name="<%= formId(align_key) %>" id="<%= formId(align_key + "-right") %>" value="right" checked="true">',
          '<label for="<%= formId(align_key + "-right") %>">Left</label>',
          '<input data-key="<%= align_key %>" type="radio" name="<%= formId(align_key) %>" id="<%= formId(align_key + "-left") %>" value="left">',
          '<label for="<%= formId(align_key + "-left") %>">Right</label>',
        '</div>',
      '</div>',
      '<div class="clearFix"></div>',
    '</div>'
  ].join("\n")
  });
})();