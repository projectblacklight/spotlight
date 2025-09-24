export default class {
  connect() {
    if ($.fn.carousel) {
      const $carousel = $('.carousel');

      // updates the aria-describedby on the next and prev btns
      const updateAriaDescribedBy = function ($carousel) {
        const $activeItem = $carousel.find('.carousel-item.active');
        const $items = $carousel.find('.carousel-item');
        const curIndex = $items.index($activeItem);
        const prevIndex = (curIndex - 1 + $items.length) % $items.length;
        const nextIndex = (curIndex + 1) % $items.length;

        const prevDataId = $items.eq(prevIndex).data('id');
        const nextDataId = $items.eq(nextIndex).data('id');
        if (prevDataId) {
          $carousel.find('.carousel-control-prev').attr('aria-describedby', 'carousel-caption-' + prevDataId);
        }
        if (nextDataId) {
          $carousel.find('.carousel-control-next').attr('aria-describedby', 'carousel-caption-' + nextDataId);
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