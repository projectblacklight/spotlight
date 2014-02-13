Spotlight.onLoad(function() {
  $("#another-email").on("click", function() {
    container = $(this).parent().parent();
    input = container.find('.input-group input[type="text"]').first().clone();
    input.val('');
    input.attr('id', input.attr('id').replace('0', container.children().length));
    input.attr('name', input.attr('name').replace('0', container.children().length));
    container.append(input);
  });

  $('.btn-with-tooltip').tooltip();
});
