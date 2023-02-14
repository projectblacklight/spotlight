export default class {
  connect() {
    var $container, slider;

    function init() {
      var data = $container.data();
      var sidebar = $container.data().sidebar;
      var items = data.browseGroupCategoriesCount;
      var dir = $('html').attr('dir');
      var controls = $container.parent().find('.browse-group-categories-controls')[0];

      slider = tns({
        container: $container[0],
        controlsContainer: controls,
        loop: false,
        nav: false,
        items: 1,
        slideBy: 'page',
        textDirection: dir,
        responsive: {
          576: {
            items: itemCount(items, sidebar)
          }
        }
      });
    }

    // Destroy the slider instance, as tns will change the dom elements, causing some issues with turbolinks
    function setupDestroy() {
      document.addEventListener('turbolinks:before-cache', function() {
        if (slider && slider.destroy) {
          slider.destroy();
        }
      });
    }

    function itemCount(items, sidebar) {
      if (items < 3) {
        return items;
      }
      return sidebar ? 3 : 4;
    }

    return $('[data-browse-group-categories-carousel]').each(function() {
      $container = $(this);
      init();
      setupDestroy();
    });
  }
}
