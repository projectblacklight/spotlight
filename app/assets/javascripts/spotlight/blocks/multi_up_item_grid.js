/*
  Sir Trevor MutliUpItemGrid Block.
  This block takes an ID,
  fetches the record from solr,
  displays the image, title,
  and any provided text
  and displays them.
*/

SirTrevor.Blocks.MultiUpItemGrid =  (function(){
  
  return Spotlight.Block.extend({

    key: "item-grid",
    id_key: "item-grid-id",
    display_checkbox: "item-grid-display",
    panel: 'typeahead-panel',
    thumbnail_key: 'item-grid-thumbnail',
    primary_field_key: "item-grid-primary-caption-field",
    show_primary_caption: "show-primary-caption",
    secondary_field_key: "item-grid-secondary-caption-field",
    show_secondary_caption: "show-secondary-caption",
    title_key: "spotlight_title_field",

    type: "multi-up-item-grid",

    title: function() { return "Multi-Up Item Grid"; },

    icon_name: "multi-up-item-grid",

    onBlockRender: function() {
      Spotlight.Block.prototype.onBlockRender.apply();
      this.loadCaptionField();
      this.addCaptionSelectFocus();
      this.makeItemGridNestable();
    },

    afterLoadData: function(data){
      // set a data attribute on the select fields so the ajax request knows which option to select
      this.$('select#' + this.formId(this.primary_field_key)).data('select-after-ajax', data[this.primary_field_key]);
      this.$('select#' + this.formId(this.secondary_field_key)).data('select-after-ajax', data[this.secondary_field_key]);
      var context = this;
      var i = 0;
      context.$('[data-target-panel]').each(function(){
        if ($(this).prop("value") != "") {
          swapInputForPanel($(this), context.$($(this).data('target-panel')), {
            id: data[context.id_key + "_" + i],
            title: data[context.id_key + "_" + i + "_title"],
            thumbnail: data[context.thumbnail_key + "_" + i]
          });
        }
        i++;
      });
    },

    description: "This widget displays one to five thumbnail images of repository items in a single row grid. Optionally, you can a caption below each image..",

    template: _.template([
    '<div class="form-inline <%= key %>-admin clearfix">',
      '<div class="widget-header">',
        '<%= description %>',
      '</div>',
      '<div class="col-sm-8">',
        '<label for="<%= formId(id_key) %>_0" class="control-label">Selected items to display</label>',
        '<div class="form-group panel-group dd nestable-item-grid">',
          '<ol class="dd-list">',
            '<%= buildInputFields(inputFieldsCount) %>',
          '</ol>',
        '</div>',
      '</div>',
      '<div class="col-sm-4">',
        '<div class="field-select primary-caption" data-behavior="item-caption-admin">',
          '<input name="<%= show_primary_caption %>" id="<%= formId(show_primary_caption) %>" type="checkbox" value="true" />',
          '<label for="<%= formId(show_primary_caption) %>">Primary caption</label>',
          '<select name="<%= primary_field_key %>" id="<%= formId(primary_field_key) %>">',
            '<option value="">Select...</option>',
            '<%= caption_field_template({field: title_key, label: "Title", selected: ""}) %>',
          '</select>',
        '</div>',
        '<div class="field-select secondary-caption" data-behavior="item-caption-admin">',
          '<input name="<%= show_secondary_caption %>" id="<%= formId(show_secondary_caption) %>" type="checkbox" value="true" />',
          '<label for="<%= formId(show_secondary_caption) %>">Secondary caption</label>',
          '<select name="<%= secondary_field_key %>" id="<%= formId(secondary_field_key) %>">',
            '<option value="">Select...</option>',
            '<%= caption_field_template({field: title_key, label: "Title", selected: ""}) %>',
          '</select>',
        '</div>',
      '</div>',
    '</div>'
  ].join("\n")),

  makeItemGridNestable: function() {
    $('.nestable-item-grid').nestable({maxDepth: 1});
    $('.nestable-item-grid').on('change', function(){
      var i = 0;
      $('li.dd-item', $(this)).each(function(){
        $("[data-nestable-observe]", $(this)).each(function(){
          replaceName($(this), i)
        });
        replaceName($("[data-target-panel='#" + $(this).attr('id') + "']"), i);
        i++;
      });
    });
    addRemoveAutocompletedPanelBehavior();
  },

  inputFieldsCount: 5,

  buildInputFields: function(times) {
    output = '<input type="hidden" name="<%= id_key %>_count" value="' + times + '"/>';
    for(var i=0; i < times; i++){
      output += '<div class="col-sm-11 field">';
        output += '<li class="dd-item dd3-item" style="display:none" data-id="' + (i+1) + '" id="<%= formId(panel + "_' + i + '") %>">';
          output += '<div class="dd-handle dd3-handle">Drag</div>';
          output += '<div class="dd3-content panel panel-default">';
            output += '<div class="panel-heading item-grid">';
              output += '<div class="checkbox">';
                output += '<input name="<%= display_checkbox + "_' + i + '" %>" id="<%= formId(display_checkbox + "_' + i + '") %>" type="checkbox" class="item-grid-checkbox" value="true" data-nestable-observe="true" />';
              output += '</div>';
              output += '<div class="pic thumbnail">';
                output += '<img style="display:none" />';
                output += '<input type="hidden" name="<%= thumbnail_key + "_' + i + '" %>" id="<%= formId(thumbnail_key + "_' + i + '") %>" data-item-grid-thumbnail="true" data-nestable-observe="true" />';
              output += '</div>';
              output += '<div class="main">';
                output += '<div class="title panel-title" data-panel-title="true"></div>';
                output += '<div data-panel-id-display="true"></div>';
              output += '</div>';
              output += '<div class="remove pull-right">';
                output += '<a data-item-grid-panel-remove="true" href="#">Remove</a>'
              output += '</div>';
              output += '<input name="<%= id_key + "_' + i + '" %>" class="item-grid-input" type="hidden" id="<%= formId(id_key + "_' + i + '") %>" data-nestable-observe="true" />';
            output += '</div>';
          output += '</div>';
        output += '</li>';
        output += '<input data-target-panel="#<%= formId(panel + "_' + i + '") %>" data-checkbox_field="#<%= formId(display_checkbox + "_' + i + '") %>" data-id_field="#<%= formId(id_key + "_' + i + '") %>" name="<%= id_key + "_' + i + '_title" %>" class="st-input-string item-grid-input form-control" data-twitter-typeahead="true" type="text" id="<%= formId(id_key + "_' + i + '_title") %>" data-nestable-observe="true" />';
      output += '</div>';
    }
    return _.template(output)(this);
  }
  });
})();
