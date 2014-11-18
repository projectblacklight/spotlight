Spotlight = function() {
  var buffer = new Array;
  return {
    onLoad: function(func) {
      buffer.push(func);
    },

    activate: function() {
      for(var i = 0; i < buffer.length; i++) {
        buffer[i].call();
      }
    }
  }
}();

if (typeof Turbolinks !== "undefined") {
  $(document).on('page:load', function() {
    Spotlight.activate();
  });
}
$(document).ready(function() {
  Spotlight.activate();
});


Spotlight.onLoad(function(){
  SpotlightNestable.init();
  $.each($('.social-share-button a'), function() {
    $(this).append($(this).attr('title'));
  });
});

