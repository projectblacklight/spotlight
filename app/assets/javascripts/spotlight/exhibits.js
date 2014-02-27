Spotlight.onLoad(function() {
  $("#another-email").on("click", function() {
    container = $(this).closest('.form-group').children('div');
    input = container.find('.input-group input[type="text"]').first().clone();
    input.val('');
    input.attr('id', input.attr('id').replace('0', container.find('input[type="text"]').length));
    input.attr('name', input.attr('name').replace('0', container.find('input[type="text"]').length));
    container.find('.help-block').before(input);
    new_container = input.wrap( "<div class=\"row\"><div class=\"col-md-6\"></div></div>" )
  });

  $('.btn-with-tooltip').tooltip();
});
