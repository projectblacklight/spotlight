Spotlight.onLoad(function() {
  serializeObservedForms(observedForms());
});
// All the observed forms
function observedForms(){
  return $('[data-form-observer]');
}
// Serialize all observed forms on the page
function serializeObservedForms(forms){
  forms.each(function(){
    serializeFormStatus($(this));
    unbindObservedFormSubmit();
  });
}
// Unbind observing form on submit (which we have to do because of turbolinks)
function unbindObservedFormSubmit(){
  observedForms().each(function(){
    $(this).on("submit", function(){
      $(this).data("being-submitted", true);
    });
  });
}
// Store form serialization in data attribute
function serializeFormStatus(form){
  form.data("serialized-form", formSerialization(form));
}
// Do custom serialization of the sir-trevor form data
function formSerialization(form){
  var content_editable = [];
  var i=0;
  $("[contenteditable='true']", form).each(function(){
    content_editable.push("&contenteditable_" + i + "=" + $(this).text());
  });
  return form.serialize() + content_editable.join();
}
// Get the stored serialized form status
function serializedFormStatus(form){
  return form.data("serialized-form");
}
// Check all observed forms on page for status change
function observedFormsStatusHasChanged(){
  var unsaved_changes = false;
  observedForms().each(function(){
    if ( !$(this).data("being-submitted") ) {
      if (serializedFormStatus($(this)) != formSerialization($(this))) {
        unsaved_changes = true;
      }
    }
  });
  return unsaved_changes;
}
// Compare stored and current form serializations
// to determine if the form has changed before
// unload and before any turbolinks change event
$(window).on('beforeunload page:before-change', function(event) {
  if ( observedFormsStatusHasChanged() ) {
    var message = "You have unsaved changes. Are you sure you want to leave this page?";
    if ( event.type == "beforeunload" ) {
      return message;
    }else{
      return confirm(message)
    }
  }
});