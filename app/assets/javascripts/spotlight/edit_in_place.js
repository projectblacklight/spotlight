Spotlight.onLoad(function() {
  $('[data-in-place-edit-target]').spotlightEditInPlace();
});
/*
  Simple plugin add edit-in-place behavior
*/
(function($) {
  $.fn.spotlightEditInPlace = function() {
    var clickElements = this;

    $(clickElements).each(function() {
      $(this).on('click.inplaceedit', function() {
        var $label = $(this).find($(this).data('in-place-edit-target'));
        var $input = $(this).find($(this).data('in-place-edit-field-target'));

        // hide the edit-in-place affordance icon while in edit mode
        $(this).addClass('hide-edit-icon');
        $label.hide();
        $input.val($label.text());
        $input.attr('type', 'text');
        $input.select();
        $input.focus();

        $input.on('keypress', function(e) {
          if(e.which == 13) {
            $input.trigger('blur.inplaceedit');
            return false;
          }
        });

        $input.on('blur.inplaceedit', function() {
          $label.text($input.val());
          $label.show();
          $input.attr('type', 'hidden');
          // when leaving edit mode, should no longer hide edit-in-place affordance icon
          $("[data-in-place-edit-target]").removeClass('hide-edit-icon');

          return false;
        });

        return false;
      });
    });

    return this;
  };
})(jQuery);
