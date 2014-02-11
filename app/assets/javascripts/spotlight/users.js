(function( $ ){

  $.fn.spotlight_users = function( options ) {  

    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);

    function edit_user(event) {
      event.preventDefault();
      $(this).closest('tr').hide();
      id = $(this).attr('data-target')
      edit_view = $("[data-edit-for='"+id+"']").show();
      $.each(edit_view.find('input[type="text"], select'), function() {
        // Cache original values incase editing is canceled
        $(this).data('orig', $(this).val());
      });
    }

    function cancel_edit(event) {
      event.preventDefault();
      id = $(this).closest('tr').attr('data-edit-for');
      edit_view = $("[data-edit-for='"+id+"']").hide();
      $.each(edit_view.find('input[type="text"], select'), function() {
        // Rollback changes
        $(this).val($(this).data('orig'));
      });
      $("[data-show-for='"+id+"']").show();
    }

    function destroy_user(event) {
      id = $(this).attr('data-target')
      $("[data-destroy-for='"+id+"']").val('1');

    }

    return this.each(function() {        
      $('[data-edit-for]').hide();

      $("[data-behavior='edit-user']", this).on('click', edit_user);
      $("[data-behavior='cancel-edit']", this).on('click', cancel_edit);
      $("[data-behavior='destroy-user']", this).on('click', destroy_user);
    });
  };
})( jQuery );


Spotlight.onLoad(function() {
  $('.edit_exhibit').spotlight_users();
});
