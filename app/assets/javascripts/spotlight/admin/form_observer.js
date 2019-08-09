Spotlight.onLoad(function() {
  // Instantiate the singleton SerializedForm plugin
  var serializedForm = $.SerializedForm();
  $(window).on('beforeunload page:before-change turbolinks:before-visit', function(event) {
    // Don't handle the same event twice #turbolinks
    if (event.handled !== true) {
      if ( serializedForm.observedFormsStatusHasChanged() ) {
        event.handled = true;
        var message = "You have unsaved changes. Are you sure you want to leave this page?";
        // There are variations in how Webkit browsers may handle this:
        // https://developer.mozilla.org/en-US/docs/Web/Events/beforeunload
        if ( event.type == "beforeunload" ) {
          return message;
        }else{
          
          return confirm(message)
        }
      }
    }
  });
});

(function($, undefined) {
  'use strict';

  /*
  * SerializedForm is built as a singleton jQuery plugin. It needs to be able to
  * handle instantiation from multiple sources, and use the [data-form-observer]
  * as global state object.
  */
  $.SerializedForm = function () {
    var $serializedForm;
    var plugin = this;

    // Store form serialization in data attribute
    function serializeFormStatus () {
      $serializedForm.data('serialized-form', formSerialization($serializedForm));
    }

    // Do custom serialization of the sir-trevor form data. This needs to be a
    // passed in argument for comparison later on.
    function formSerialization (form) {
      var content_editable = [];
      var i = 0;
      $("[contenteditable='true']", form).each(function(){
        content_editable.push('&contenteditable_' + i + '=' + $(this).text());
      });
      return form.serialize() + content_editable.join();
    }

    // Unbind observing form on submit (which we have to do because of turbolinks)
    function unbindObservedFormSubmit () {
      $serializedForm.on('submit', function () {
        $(this).data('being-submitted', true);
      });
    }

    // Get the stored serialized form status
    function serializedFormStatus () {
      return $serializedForm.data('serialized-form');
    }

    // Check all observed forms on page for status change
    plugin.observedFormsStatusHasChanged = function () {
      var unsaved_changes = false;
      $('[data-form-observer]').each(function (){
        if ( !$(this).data("being-submitted") ) {
          if (serializedFormStatus() != formSerialization($(this))) {
            unsaved_changes = true;
          }
        }
      });
      return unsaved_changes;
    }

    function init () {
      $serializedForm = $('[data-form-observer]');
      serializeFormStatus();
      unbindObservedFormSubmit();
    }

    init();

    return plugin;
  };
})(jQuery);
