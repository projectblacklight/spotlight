/*
  Block to get allow a user to choose browse
  categories to feature on various pages.
*/

SirTrevor.Blocks.FeaturedPages =  (function(){

  return Spotlight.Block.extend({

    searches_key: "featured-pages",

    blockGroup: 'Exhibit item widgets',

    description: "This block visually highlights up to five other pages",

    inputFieldsCount: 5,

    type: "featured_pages",

    title: function() { return "Featured Pages"; },

    icon_name: 'featured_pages',
    
    key: "page-grid",
    id_key: "page-grid-id",
    display_checkbox: "page-grid-display",
    panel: 'page-typeahead-panel',
    
    onBlockRender: function() {
      //Spotlight.Block.prototype.onBlockRender.apply();
      
      addAutocompletetoSirTrevorForm({ bloodhound: this.bloodhound});
      this.loadCaptionField();
      this.addCaptionSelectFocus();
      this.makeItemGridNestable();
    },

    bloodhound: function() {
      var results = new Bloodhound({
        datumTokenizer: function(d) { 
          window.console.log(d);
          return Bloodhound.tokenizers.whitespace(d.title); 
        },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        limit: 10,
        remote: {
          url: $('form[data-pages-url]').data('pages-url'),
          filter: function(response) {
            return $.map(response, function(doc) {
              return doc;
            })
          }
        }
      });
      results.initialize();
      return results;
    },

    afterLoadData: function(data){
      var context = this;
      context.$('[data-target-panel]').each(function(i){
        if ($(this).prop("value") != "") {
          var target_panel = $(this),
              object_id = data[context.id_key + "_" + i],
              object_title = data[context.id_key + "_" + i + "_title"];
          var ajaxData = page_data(object_id);
          swapInputForPanel(target_panel, context.$(target_panel.data('target-panel')), {
            id: object_id,
            title: object_title
          });
        }
      });
    },
    
    template: [
      '<div class="form-inline <%= key %>-admin clearfix">',
        '<div class="widget-header">',
          '<%= description %>',
        '</div>',
        '<div class="col-sm-8">',
          '<label for="<%= formId(id_key) %>_0" class="control-label">Selected pages to display</label>',
          '<div class="form-group panel-group dd nestable-item-grid" data-behavior="nestable" data-max-depth="1">',
            '<ol class="dd-list">',
              '<%= buildInputFields(inputFieldsCount) %>',
            '</ol>',
          '</div>',
        '</div>',
      '</div>'
    ].join("\n"),
    
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
                output += '<div class="main">';
                  output += '<div class="title panel-title" data-panel-title="true"></div>';
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

  });
})();