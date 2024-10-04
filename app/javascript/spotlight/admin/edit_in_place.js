/*
  Simple plugin add edit-in-place behavior
*/
export default class {
  connect() {
    $('[data-in-place-edit-target]').each(function() {
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
          var value = $input.val();

          if ($.trim(value).length == 0) {
            $input.val($label.text());
          } else {
            $label.text(value);
          }

          $label.show();
          $input.attr('type', 'hidden');
          // when leaving edit mode, should no longer hide edit-in-place affordance icon
          $("[data-in-place-edit-target]").removeClass('hide-edit-icon');

          return false;
        });

        return false;
      });
    })

    $("[data-behavior='restore-default']").each(function(){
      var hidden = $("[data-default-value]", $(this));
      var value = $($("[data-in-place-edit-target]", $(this)).data('in-place-edit-target'), $(this));
      var button = $("[data-restore-default]", $(this));
      hidden.on('blur', function(){
        if( $(this).val() == $(this).data('default-value') ) {
          button.addClass('d-none');
        } else {
          button.removeClass('d-none');
        }
      });
      button.on('click', function(e){
        e.preventDefault();
        hidden.val(hidden.data('default-value'));
        value.text(hidden.data('default-value'));
        button.hide();
      });
    });
  }
}
