(function( $ ){

  $.fn.spotlight_users = function( options ) {

    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);
    var container;

    function edit_user(event) {
      event.preventDefault();
      $(this).closest('tr').hide();
      id = $(this).attr('data-target')
      edit_view = $("[data-edit-for='"+id+"']", container).show();
      $.each(edit_view.find('input[type="text"], select'), function() {
        // Cache original values incase editing is canceled
        $(this).data('orig', $(this).val());
      });
    }

    function cancel_edit(event) {
      event.preventDefault();
      id = $(this).closest('tr').attr('data-edit-for');
      edit_view = $("[data-edit-for='"+id+"']", container).hide();
      clear_errors(edit_view);
      rollback_changes(edit_view);
      $("[data-show-for='"+id+"']", container).show();
    }

    function clear_errors(element) {
      element.find('.has-error')
             .removeClass('has-error')
             .find('.help-block')
             .remove(); // Remove the error messages
    }

    function rollback_changes(element) {
      $.each(element.find('input[type="text"], select'), function() {
        $(this).val($(this).data('orig')).trigger('change');
      });
    }

    function destroy_user(event) {
      id = $(this).attr('data-target')
      $("[data-destroy-for='"+id+"']", container).val('1');
    }

    function new_user(event) {
      event.preventDefault();
      edit_view = $("[data-edit-for='new']", container).show();
      $.each(edit_view.find('input[type="text"], select'), function() {
        // Cache original values incase editing is canceled
        $(this).data('orig', $(this).val());
      });
    }

    function open_errors() {
      edit_row = container.find('.has-error').closest('[data-edit-for]');
      edit_row.show();
      // The following row has the controls, so show it too.
      edit_row.next().show();
    }

    return this.each(function() {

      container = $(this);
      $('[data-edit-for]', container).hide();
      open_errors();
      $("[data-behavior='edit-user']", container).on('click', edit_user);
      $("[data-behavior='cancel-edit']", container).on('click', cancel_edit);
      $("[data-behavior='destroy-user']", container).on('click', destroy_user);
      $("[data-behavior='new-user']", container).on('click', new_user);
    });
  };
})( jQuery );


Spotlight.onLoad(function() {
  $('.edit_exhibit, .admin-users').spotlight_users();
});
