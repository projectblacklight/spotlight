(function($){
  $.fn.addNewPageButton = function( options ) {
    $.each(this, function(){
      addExpandBehaviorToButton($(this));
    });
    function addExpandBehaviorToButton(button){
      var settings = $.extend({
        speed: (button.data('speed') || 450),
        animate_width: (button.data('animate_width') || 425)
      }, options);
      var target = $(button.data('field-target'));
      var save   = $("input[data-behavior='save']", target);
      var cancel = $("input[data-behavior='cancel']", target);
      var input  = $("input[type='text']", target);
      var original_width  = button.outerWidth();

      // Animate button open when the mouse enters or
      // the button is given focus (i.e. clicked/tabbed)
      button.on("mouseenter focus", function(){
        expandButton();
      });

      // Don't allow blank titles
      save.on('click', function(){
        if ( inputEmpty() ) {
          return false;
        }
      });

      // Empty input and collapse
      // button on cancel click
      cancel.on('click', function(e){
        e.preventDefault();
        input.val('');
        collapseButton();
      });

      // Collapse the button on when
      // an empty input loses focus
      input.on("blur", function(){
        if ( inputEmpty() ) {
          collapseButton();
        }
      });
      function expandButton(){
        if(button.outerWidth() <= (original_width + 5)) {
          button.animate(
            {width: settings.animate_width + 'px'}, settings.speed, function(){
              target.show(0, function(){
                input.focus();
                // Set the button to auto width to make
                // sure it has room for any inputs
                button.width("auto");
                // Explicitly set the width of the button
                // so the close animation works properly
                button.width(button.width());
              });
            }
          )
        }
      }
      function collapseButton(){
        target.hide();
        button.animate({width: original_width + 'px'}, settings.speed);
      }
      function inputEmpty(){
        return $.trim(input.val()) == "";
      }
    }
  }
})( jQuery );
Spotlight.onLoad(function() {
  $("[data-expanded-add-button]").addNewPageButton();
});
