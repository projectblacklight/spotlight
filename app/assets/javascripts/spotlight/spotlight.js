Spotlight = function() {
  var buffer = [];
  return {
    onLoad: function(func) {
      buffer.push(func);
    },

    activate: function() {
      for(var i = 0; i < buffer.length; i++) {
        buffer[i].call();
      }
    }
  };
}();

Blacklight.onLoad(function() {
  Spotlight.activate();
});

Spotlight.onLoad(function(){
  SpotlightNestable.init();
  $.each($('.social-share-button a'), function() {
    $(this).append($(this).attr('title'));
  });
});

