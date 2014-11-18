Spotlight.onLoad(function(){
  addRestoreDefaultBehavior();
});

function addRestoreDefaultBehavior(){
  $("[data-behavior='restore-default']").each(function(){
    var hidden = $("[data-default-value]", $(this));
    var value = $($("[data-in-place-edit-target]", $(this)).data('in-place-edit-target'), $(this));
    var button = $("[data-restore-default]", $(this));
    hidden.on('blur', function(){
      if( $(this).val() == $(this).data('default-value') ) {
        button.addClass('hidden');
      } else {
        button.removeClass('hidden');
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