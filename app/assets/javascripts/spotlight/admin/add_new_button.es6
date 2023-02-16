export default class {
  connect() {
    $("[data-expanded-add-button]").each((_i, el) => this.addExpandBehaviorToButton($(el)))
  }

  addExpandBehaviorToButton(button){
    var settings = {
      speed: (button.data('speed') || 450),
      animate_width: (button.data('animate_width') || 425)
    }
    var target = $(button.data('field-target'));
    var save   = $("input[data-behavior='save']", target);
    var cancel = $("input[data-behavior='cancel']", target);
    var input  = $("input[type='text']", target);
    var original_width  = button.outerWidth();
    var expanded = false;

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
      // If this has not yet been expanded, recalculate original_width to 
      // handle things that may have been originally hidden.
      if (!expanded) {
        original_width  = button.outerWidth();
      }
      if(button.outerWidth() <= (original_width + 5)) {
        expanded = true;
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
