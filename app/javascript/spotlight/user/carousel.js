export default class {
  connect() {
    if ($.fn.carousel) {
      const $carousel = $('.carousel');

      // updates the aria-describedby on the next and prev btns
      const updateAriaDescribedBy = function ($carousel) {
        const $activeItem = $carousel.find('.carousel-item.active');
        const prevId = $activeItem.data('prev-id');
        const nextId = $activeItem.data('next-id');
        if (prevId) {
          $carousel.find('.carousel-control-prev').attr('aria-describedby', prevId);
        }
        if (nextId) {
          $carousel.find('.carousel-control-next').attr('aria-describedby', nextId);
        }
      };

      // on initial page load, set the aria-describedby on the btns for each carousel
      $carousel.each(function () {
        const $this = $(this);
        $this.carousel();
        updateAriaDescribedBy($this);
      });

      // on slide change
      $carousel.on('slid.bs.carousel', function () {
        updateAriaDescribedBy($(this));
      });
    }
  }
}