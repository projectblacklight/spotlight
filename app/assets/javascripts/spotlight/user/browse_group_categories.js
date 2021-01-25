(function( $ ){

  $.fn.browseGroupCategories = function( options ) {
    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);
    var $container, slider;

    function init() {
      slider = tns({
        container: $container[0],
        controlsContainer: $container.parent().find('.browse-group-categories-controls')[0],
        loop: false,
        nav: false,
        items: 1,
        gutter: 20,
        slideBy: 'page',
        responsive: {
          576: {
            items: 3
          }
        }
      });
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
