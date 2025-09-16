export default class {
  connect() {
    if ($.fn.carousel) {
      $('.carousel').carousel();

      // when slide changes, update the aria-describedby on the next and prev btns
      $('.carousel').on('slid.bs.carousel', function () {
        var $activeItem = $(this).find('.carousel-item.active');
        var prevId = $activeItem.data('prev-id');
        var nextId = $activeItem.data('next-id');
        if (prevId) {
          $(this).find('.carousel-control-prev').attr('aria-describedby', prevId);
        }
        if (nextId) {
          $(this).find('.carousel-control-next').attr('aria-describedby', nextId);
        }
      });
    }
  }
}
