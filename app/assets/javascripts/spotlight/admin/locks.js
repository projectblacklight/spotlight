Spotlight.onLoad(function(){


  function delete_lock(el) {
    $.ajax({ url: $(el).data('lock'), type: 'POST', data: { _method: "delete" }, async: false});
    $(el).removeAttr('data-lock');
  }

  $('[data-lock]').on('click', function(e) {
    delete_lock(this);
  });
});