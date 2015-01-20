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
    auto_play_images_key: "auto-play-images",
    auto_play_images_interval_key: "auto-play-images-interval",
    max_height_key: "max-height",
    title_key: "spotlight_title_field",

    type: "multi-up-item-grid",

    title: function() { return "Multi-Up Item Grid"; },

    blockGroup: 'Exhibit item widgets',

    icon_name: "multi-up-item-grid",

    inputFieldsCount: 5,

    carouselCycleTimesInSeconds: {
      values: [ 3, 5, 8, 12, 20 ],
      selected: 5
    },

    carouselMaxHeights: {
      values: { 'Small': 200, 'Medium': 350, 'Large': 500 },
      selected: 'Medium'
    },

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
      context.$('[data-target-panel]').each(function(i){
        if ($(this).prop("value") != "") {
          var target_panel = $(this),
              object_id = data[context.id_key + "_" + i],
              object_title = data[context.id_key + "_" + i + "_title"],
              object_thumbnail = data[context.thumbnail_key + "_" + i];
          $.ajax($('form[data-autocomplete-url]').data('autocomplete-url') + '?q=id:' + object_id).success(function(ajaxData){
            var thumbnails   = ajaxData['docs'][0]['thumbnails'],
                privateLabel = ajaxData['docs'][0]['private'];
            swapInputForPanel(target_panel, context.$(target_panel.data('target-panel')), {
              id: object_id,
              title: object_title,
              thumbnail: object_thumbnail,
              thumbnails: thumbnails,
              private: privateLabel
            });
          });
        }
      });
    },

    description: "This widget displays one to five thumbnail images of repository items in a single row grid. Optionally, you can a caption below each image..",

    template: [
      '<div class="form-inline <%= key %>-admin clearfix">',
        '<div class="widget-header">',
          '<%= description %>',
        '</div>',
        '<div class="col-sm-8">',
          '<label for="<%= formId(id_key) %>_0" class="control-label">Selected items to display</label>',
          '<div class="form-group panel-group dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">',
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
              '<%= _.template(caption_field_template)({field: title_key, label: "Title", selected: ""}) %>',
            '</select>',
          '</div>',
          '<div class="field-select secondary-caption" data-behavior="item-caption-admin">',
            '<input name="<%= show_secondary_caption %>" id="<%= formId(show_secondary_caption) %>" type="checkbox" value="true" />',
            '<label for="<%= formId(show_secondary_caption) %>">Secondary caption</label>',
            '<select name="<%= secondary_field_key %>" id="<%= formId(secondary_field_key) %>">',
              '<option value="">Select...</option>',
              '<%= _.template(caption_field_template)({field: title_key, label: "Title", selected: ""}) %>',
            '</select>',
          '</div>',
          '<%= addCarouselFields() %>',
        '</div>',
      '</div>'
    ].join("\n"),

    makeItemGridNestable: function() {
      SpotlightNestable.init();
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


    buildInputFields: function(times) {
      var output = '<input type="hidden" name="<%= id_key %>_count" value="' + times + '"/>';

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
                  output += '<div data-panel-image-pagination="true"></div>';
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
    },


    addCarouselFields: function() {
      var tpl = '';

      if (this.type === 'item-carousel') {
        tpl = [
          '<div class="field-select auto-cycle-images" data-behavior="auto-cycle-images">',
            '<input name="<%= auto_play_images_key %>" id="<%= formId(auto_play_images_key) %>" data-key="<%= auto_play_images_key %>" type="checkbox" value="true" checked/>',
            '<label for="<%= formId(auto_play_images_key) %>">Automatically cycle images</label>',
            '<select name="<%= auto_play_images_interval_key %>" id="<%= formId(auto_play_images_interval_key) %>" data=key="<%= auto_play_images_interval_key %>">',
              '<option value="">Select...</option>',
              '<%= addCarouselCycleOptions(carouselCycleTimesInSeconds) %>',
            '</select>',
          '</div>',
          '<div class="field-select max-heights" data-behavior="max-heights">',
            '<label for="<%= formId(max_height_key) %>">Maximum carousel height</label><br/>',
            '<%= addCarouselMaxHeightOptions(carouselMaxHeights) %>',
          '</div>',
        ].join("\n");
      }


      return _.template(tpl)(this);
    },

    addCarouselCycleOptions: function(options) {
      var html = '';

      $.each(options.values, function(index, interval) {
        var selected = (interval === options.selected) ? 'selected' : '',
            intervalInMilliSeconds = parseInt(interval, 10) * 1000;

        html += '<option value="' + intervalInMilliSeconds + '" ' + selected + '>' + interval + ' seconds</option>';
      });

      return html;
    },

    addCarouselMaxHeightOptions: function(options) {
      var html = '',
          _this = this;

      $.each(options.values, function(size, px) {
        var checked = (size === options.selected) ? 'checked' : '',
            id = _this.formId(_this.max_height_key)

        html += '<input data-key="' + _this.max_height_key + '" type="radio" name="' + id + '" value="' + px + '" id="' + id + '" ' + checked + '>';
        html += '<label class="carousel-size" for="' + id + '">' + size + '</label>';
      });

      return html;
    }

  });
})();
