// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require sir-trevor
//= require_tree .

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