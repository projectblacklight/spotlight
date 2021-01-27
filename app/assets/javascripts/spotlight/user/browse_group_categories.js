(function( $ ){

  $.fn.browseGroupCategories = function( options ) {
    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);
    var $container, slider;

    function init() {
      var data = $container.data();
      var sidebar = $container.data().sidebar;
      var items = data.browseGroupCategoriesCount;

      slider = tns({
        container: $container[0],
        controlsContainer: $container.parent().find('.browse-group-categories-controls')[0],
        loop: false,
        nav: false,
        items: 1,
        slideBy: 'page',
        responsive: {
          576: {
            items: itemCount(items, sidebar)
          }
        }
      });
    }

    function itemCount(items, sidebar) {
      if (items < 3) {
        return items;
      }
      return sidebar ? 3 : 4;
    }

    return this.each(function() {
      $container = $(this);
      init();
    });
  }
})( jQuery );

Spotlight.onLoad(function() {
  $('[data-browse-group-categories-carousel]').each(function(i, el) {
    $(el).browseGroupCategories();
  });
});
