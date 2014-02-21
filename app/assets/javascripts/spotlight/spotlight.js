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

SirTrevor.setDefaults({
  uploadUrl: "/spotlight/attachments"
});

Spotlight.onLoad(function(){
  var instances = $('.sir-trevor-area'),
      l = instances.length, instance;

  while (l--) {
    instance = $(instances[l]);
    new SirTrevor.Editor({ el: instance });
  }

});



Spotlight.onLoad(function(){
  $.each($('.social-share-button a'), function() {
    $(this).append($(this).attr('title'));
  });
});

