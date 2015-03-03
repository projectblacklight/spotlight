Spotlight.onLoad(function() {
  $('[data-input-select-target]').selectRelatedInput();
});
/*
  Simple plugin to select form elements
  when other elements are clicked.
*/
(function($) {
  $.fn.selectRelatedInput = function() {
    var clickElements = this;

    $(clickElements).each(function() {
      var target = $($(this).data('input-select-target'));
      $(this).on('click', function(){
        target.prop('checked', true);
      });
    });

    return this;
  };
})(jQuery);
