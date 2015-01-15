/*
  Simple Image Block
*/

SirTrevor.Blocks.SearchResults =  (function(){

  return Spotlight.Block.extend({

  searches_key: "searches-options",

  view_types_key: '[data-behavior="result-view-types"]',

  blockGroup: 'Exhibit item widgets',

  description: "This widget displays a set of search results on a page. Specify a search result set by selecting an existing browse category. You can also select the view types that are available to the user when viewing the result set.",

  template: [
    '<div class="search-block-admin clearFix">',
      '<div class="widget-header">',
        '<%= description %>',
      '</div>',
      '<div class="col-sm-8">',
        '<label for="<%= formId(searches_key) %>">Browse category</label>',
        '<div>',
          '<select name="<%= searches_key %>" id="<%= formId(searches_key) %>">',
            '<option value="">Select...</option>',
          '</select>',
        '</div>',
      '</div>',
      '<div class="col-sm-4" data-behavior="result-view-types">',
        '<h4>Result view types</h4>',
      '</div>',
    '</div>'
  ].join("\n"),

  onBlockRender: function(data){
    Spotlight.Block.prototype.onBlockRender.apply();
    this.loadSearchOptions();
    this.loadViewTypes();
  },

  afterLoadData: function(data){
    // set a data attribute on the select fields so the ajax request knows which option to select
    this.$('select#' + this.formId(this.searches_key)).data('select-after-ajax', data[this.searches_key]);
    this.serializeViewTypes(data);
  },

  loadSearchOptions: function(){
    var block = this;
    var searches_url = $('form[data-searches-endpoint]').data('searches-endpoint');
    var searches_field = $('#' + this.formId(this.searches_key));
    var searches_selected_value = searches_field.data("select-after-ajax");
    $.ajax({
      accepts: "json",
      url: searches_url
    }).success(function(data){
      if($("option", searches_field).length == 1){
        var options = "";
        $.each(data, function(i, search){
          options += "<option value='" + search.id + "'>" + search.title + "</option>";
        });

        searches_field.append(options);

        searches_field.val([searches_selected_value]);
        // re-serialze the form so the form observer
        // knows about the new drop dwon options.
        serializeFormStatus($('form[data-searches-endpoint]'));
      }
    });
  },

  loadViewTypes: function(){
    var view_types_url = $('form[data-available-configurations-endpoint]').data('available-configurations-endpoint');
    var selected_view_types = this.processSelectedViewTypes(this.viewTypesArea().data("select-after-ajax"));
    var block = this;
    $.ajax({
      accepts: "json",
      url: view_types_url
    }).success(function(data){
      var checkboxes = "";
      $.each(data.view, function(view_type, opts){
        checkboxes += "<div>";
          checkboxes += "<label for='" + block.formId(view_type) + "'>";
            checkboxes += "<input id='" + block.formId(view_type) + "' name='" + view_type + "' type='checkbox' " + block.checkViewType(view_type) + " /> ";
            checkboxes += block.capitalize(view_type);
          checkboxes += "</label>";
        checkboxes += "</div>";
      });
      block.viewTypesArea().append(checkboxes);
      // re-serialze the form so the form observer
      // knows about the new checkboxes.
      serializeFormStatus($('form[data-searches-endpoint]'));
    });
  },

  serializeViewTypes: function(data){
    var types = [];
    $.each(data, function(key, value){
      if ( value == "on" ) {
        types.push(key);
      }
    });
    this.viewTypesArea().data('select-after-ajax', types.join(","));
  },

  processSelectedViewTypes: function(typeString) {
    return (typeString || "").split(",");
  },

  capitalize: function (text) {
      return text.charAt(0).toUpperCase() + text.slice(1);
  },

  checkViewType: function(type){
    if (this.viewTypeSelected(type)) {
      return " checked='checked'";
    } else {
      return "";
    }
  },

  viewTypesArea: function(){
    return this.$(this.view_types_key);
  },

  viewTypeSelected: function(type){
    return (this.processSelectedViewTypes(this.viewTypesArea().data('select-after-ajax')).indexOf(type) > -1)
  },

  type: "search_results",

  title: function() { return "Search Results"; },

  icon_name: 'search_results',
});
})();