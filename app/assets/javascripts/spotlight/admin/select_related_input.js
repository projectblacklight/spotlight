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

      var event;

      if ($(this).is("select")) {
        event = 'change';
      } else {
        event = 'click';
      }

      $(this).on(event, function() {
        if (target.is(":checkbox") || target.is(":radio")) {
          target.prop('checked', true);
        } else {
          target.focus();
        }
      });
    });

    return this;
  };
})(jQuery);
