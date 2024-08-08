export default class {
  connect(){
    var container, target;

    function init() {
      const target_val = container.attr('data-target') || container.attr('data-bs-target');
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

    return $('[data-behavior="contact-link"]').each(function() {        
      container = $(this);
      init();
    });
  }
}