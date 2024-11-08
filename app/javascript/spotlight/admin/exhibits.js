import { URLify } from 'parameterize';

export default class {
  connect() {
    // auto-fill the exhibit slug on the new exhibit form
    $('#new_exhibit').each(function() {
      $('#exhibit_title').on('change keyup', function() {
        $('#exhibit_slug').attr('placeholder', URLify($(this).val(), $(this).val().length));
      });

      $('#exhibit_slug').on('focus', function() {
        if ($(this).val() === '') {
          $(this).val($(this).attr('placeholder'));
        }
      });
    });

    $("#another-email").on("click", function(e) {
      e.preventDefault();

      var container = $(this).closest('.form-group');
      var contacts = container.find('.contact');
      var inputContainer = contacts.first().clone();

      // wipe out any values from the inputs
      inputContainer.find('input').each(function() {
        $(this).val('');
        $(this).attr('id', $(this).attr('id').replace('0', contacts.length));
        $(this).attr('name', $(this).attr('name').replace('0', contacts.length));
        if ($(this).attr('aria-label')) {
          $(this).attr('aria-label', $(this).attr('aria-label').replace('1', contacts.length + 1));
        }
      });

      inputContainer.find('.contact-email-delete-wrapper').remove();
      inputContainer.find('.confirmation-status').remove();

      // bootstrap does not render input-groups with only one value in them correctly.
      inputContainer.find('.input-group input:only-child').closest('.input-group').removeClass('input-group');

      $(inputContainer).insertAfter(contacts.last());
    });

    $('.contact-email-delete').on('ajax:success', function() {
      $(this).closest('.contact').fadeOut(250, function() { $(this).remove(); });
    });

    $('.contact-email-delete').on('ajax:error', function(event, _xhr, _status, error) {
      var errSpan = $(this).closest('.contact').find('.contact-email-delete-error');
      errSpan.show();
      errSpan.find('.error-msg').first().text(error || event.detail[1]);
    });

    document.addEventListener('turbo:submit-end', (event) => {
      const response = event.detail.fetchResponse;
      if (!response.succeeded && response.response.status === 404) {
        const path = new URL(event.target.action).pathname;
        const deleteButton = document.querySelector(`.contact-email-delete[href="${path}"]`);
        if (deleteButton) {
          const errSpan = deleteButton.closest('.contact').querySelector('.contact-email-delete-error');
          const errorMsg = errSpan.querySelector('.error-msg');
          errSpan.style.display = 'block';
          errorMsg.textContent = 'Not Found';
        }
      }
    });

    if ($.fn.tooltip) {
      $('.btn-with-tooltip').tooltip();
    }

    // Put focus in saved search title input when Save this search modal is shown
    $('#save-modal').on('shown.bs.modal', function () {
        $('#search_title').focus();
    });
  }
}