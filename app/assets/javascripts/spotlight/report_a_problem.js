(function( $ ){

  $.fn.reportProblem = function( options ) {
    // Create some defaults, extending them with any options that were provided
    var settings = $.extend( { }, options);
    var container, target, cancel;

    function init() {
      target_val = container.attr('data-target')
      if (!target_val) 
        return

      target = $("#" + target_val); 
      container.on('click', open);
      target.find('[data-behavior="cancel-link"]').on('click', close);
    }

    function open(event) {
      event.preventDefault();
      target.slideToggle('slow');
    }

    function close(event) {
      event.preventDefault();
      target.slideUp('fast');
    }

    return this.each(function() {        
      container = $(this);
      init();
    });
  }
})( jQuery );

Spotlight.onLoad(function() {
  $('[data-behavior="contact-link"]').reportProblem();
});


