/*
  Block to get allow a user to choose browse
  categories to feature on various pages.
*/

SirTrevor.Blocks.FeaturedBrowseCategories =  (function(){

  return Spotlight.Block.extend({

  searches_key: "featured-browse-categories",

  blockGroup: 'Exhibit item widgets',

  description: "This block visually highlights up to five browse categories, which are linked to the browse category results page.",

  maxCategoriesAllowed: 5,

  template: [
    '<div class="featured-browse-categories-block-admin clearFix">',
      '<div class="widget-header">',
        '<%= description %>',
      '</div>',
      '<div class="col-sm-12">',
        '<label for="<%= formId(searches_key) %>">Browse categories</label>',
        '<div id="<%= formId(searches_key) %>" data-featured-browse-categories="true">',
        '</div>',
      '</div>',
    '</div>'
  ].join("\n"),

  onBlockRender: function(data){
    Spotlight.Block.prototype.onBlockRender.apply();
    this.loadSearchOptions();
  },

  afterLoadData: function(data){
    var selected = [];
    $.each(data, function(k, v){
      if(k != "display-item-counts" && !k.match(/^weight-/) && v) {
        selected.push(k);
      }
    });
    if(data["display-item-counts"]){
      selected.push("display-item-counts");
    }

    this.$('#' + this.formId(this.searches_key)).data('sort-after-ajax', this.orderData(data));
    this.$('#' + this.formId(this.searches_key)).data('select-after-ajax', selected);
  },

  orderData: function(data){
    var sortData = [];
    var sortOrder = [];
    $.each(data, function(k, v){
      if(k.match(/^weight-\S+/)){
        sortData.push({
          slug: k.replace('weight-', ''),
          sort: v
        });
      }
    });
    $.each(sortData.sort(function(a,b) {return a['sort'] > b['sort']}), function(){
      sortOrder.push($(this)[0]['slug']);
    });
    return sortOrder;
  },

  categoryTemplate: function(searches){
    var block = this;
    var output = '';
    output += '<div class="col-sm-7 form-group form-inline panel-group dd nestable-featured-browse" data-behavior="nestable" data-max-depth="1">';
      output += '<ol class="dd-list">';
      $.each(block.sortedAndPublishedSearches(searches), function(i, search){
        output += block.searchTemplate(i, search);
      });
      output += '</ol>';
    output += '</div>';
    return output;
  },

  sortedAndPublishedSearches: function(searches){
    var sortedAndPublishedSearches = [];
    $.each(this.sortedSearches(searches), function(){
      if($(this)[0].on_landing_page){
        sortedAndPublishedSearches.push($(this)[0]);
      }
    });
    return sortedAndPublishedSearches;
  },

  sortedSearches: function(searches){
    var sortOrder = this.$('#' + this.formId(this.searches_key)).data('sort-after-ajax') || [];
    return searches.sort(function(a,b){
      return sortOrder.indexOf(String(a.slug)) > sortOrder.indexOf(String(b.slug));
    });
  },

  searchTemplate: function(i, search){
    return [
      '<li class="dd-item dd3-item" data-id="' + search.slug + '">',
        '<div class="dd3-content panel panel-default">',
          '<div class="dd-handle dd3-handle">Drag</div>',
          '<div class="panel-heading item-grid">',
            '<div class="checkbox">',
              '<input data-nestable-limit-categories="true" id="' + this.formId(search.slug) + '" name="' +  search.slug + '" type="checkbox" value="true" /> ',
            '</div>',
            '<div class="pic thumbnail">',
              '<img src="' + (search.thumbnail_image_url) + '" />',
            '</div>',
            '<div class="main">',
              '<div class="title panel-title" data-panel-title="true">' + search.title + '</div>',
              search.count + ' items',
            '</div>',
            '<input type="hidden" data-property="weight" value="' + i + '" name="weight-' + search.slug + '" />',
          '</div>',
        '</div>',
      '</li>'
    ].join("\n")
  },

  showCountsTemplate: function(){
    return [
      '<div class="col-sm-3 col-sm-offset-1">',
        '<label>',
          '<input type="checkbox" name="display-item-counts" value="true" checked />',
          "Include item counts?",
        '</label>',
      '</div>'
    ].join("\n")
  },

  applySelectedFeaturedCategories: function(){
    var block = this;
    var container = block.$('#' + block.formId(block.searches_key));
    var selected = container.data('select-after-ajax') || [];
    $.each(selected, function(i, name){
      block.$('input[type="checkbox"][name="' + name + '"]', container).prop('checked', true)
    });

    if(selected.length > 0 && selected.indexOf("display-item-counts") < 0) {
      block.$('input[type="checkbox"][name="display-item-counts"]', container).prop('checked', false)
    }
  },

  applyMaxCategoryLimit: function(){
    var block = this;
    var selector = "[data-nestable-limit-categories='true']";
    this.$(selector).click(function(){
      if(block.$(selector + ":checked").length > block.maxCategoriesAllowed){
        return false;
      }
    });
  },

  loadSearchOptions: function(){
    var block = this;
    var searches_url = $('form[data-searches-endpoint]').data('searches-endpoint');
    var browseCategoryElement = this.$('#' + this.formId(this.searches_key));
    $.ajax({
      accepts: "json",
      url: searches_url
    }).success(function(data){
      browseCategoryElement.append(block.categoryTemplate(data));
      browseCategoryElement.append(block.showCountsTemplate());
      block.applySelectedFeaturedCategories();
      block.applyMaxCategoryLimit();
      SpotlightNestable.init();
      // re-serialze the form so the form observer
      // knows about the new drop dwon options.
      serializeFormStatus($('form[data-searches-endpoint]'));
    });
  },

  type: "featured_browse_categories",

  title: function() { return "Featured Browse Categories"; },

  icon_name: 'featured_browse_categories',
});
})();