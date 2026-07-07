export default class {
  connect() {
    document.querySelectorAll("[data-expanded-add-button]").forEach(el =>
      this.addExpandBehaviorToButton(el)
    )
  }

  addExpandBehaviorToButton(button){
    var settings = {
      speed: parseInt(button.dataset.speed || "450", 10),
      animate_width: parseInt(button.dataset.animateWidth || "425", 10)
    }
    var target = document.querySelector(button.dataset.fieldTarget);
    var save   = target.querySelector("input[data-behavior='save']");
    var cancel = target.querySelector("input[data-behavior='cancel']");
    var input  = target.querySelector("input[type='text']");
    var original_width  = button.offsetWidth;
    var expanded = false;

    // Animate button open when the mouse enters or
    // the button is given focus (i.e. clicked/tabbed)
    button.addEventListener("mouseenter", expandButton);
    button.addEventListener("focus", expandButton);

    // Don't allow blank titles
    save.addEventListener("click", function(e){
      if ( inputEmpty() ) {
        e.preventDefault();
        e.stopPropagation();
      }
    });

    // Empty input and collapse
    // button on cancel click
    cancel.addEventListener("click", function(e){
      e.preventDefault();
      input.value = '';
      collapseButton();
    });

    // Collapse the button on when
    // an empty input loses focus
    input.addEventListener("blur", function(){
      if ( inputEmpty() ) {
        collapseButton();
      }
    });

    function expandButton(){
      // If this has not yet been expanded, recalculate original_width to
      // handle things that may have been originally hidden.
      if (!expanded) {
        original_width  = button.offsetWidth;
      }
      if(button.offsetWidth <= (original_width + 5)) {
        expanded = true;
        var anim = button.animate(
          { width: settings.animate_width + 'px' },
          { duration: settings.speed }
        );
        anim.onfinish = function(){
          button.style.width = settings.animate_width + 'px';
          showElement(target);
          input.focus();
          // Set the button to auto width to make
          // sure it has room for any inputs
          button.style.width = 'auto';
          // Explicitly set the width of the button
          // so the close animation works properly
          button.style.width = button.offsetWidth + 'px';
        };
      }
    }
    function collapseButton(){
      target.style.display = 'none';
      var anim = button.animate(
        { width: original_width + 'px' },
        { duration: settings.speed }
      );
      anim.onfinish = function(){
        button.style.width = original_width + 'px';
      };
    }
    // Show an element that may be hidden via a CSS class by overriding with an
    // appropriate inline display value (mirrors jQuery's .show()).
    function showElement(el){
      el.style.display = '';
      if (window.getComputedStyle(el).display === 'none') {
        el.style.display = 'inline-block';
      }
    }
    function inputEmpty(){
      return input.value.trim() == "";
    }
  }
}
