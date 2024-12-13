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

    if (document.getElementById('another-email')) {
      document.addEventListener('turbo:submit-end', this.contactToDeleteNotFoundHandler);
    }

    if ($.fn.tooltip) {
      $('.btn-with-tooltip').tooltip();
    }

    // Put focus in saved search title input when Save this search modal is shown
    $('#save-modal').on('shown.bs.modal', function () {
        $('#search_title').focus();
    });
  }

  contactToDeleteNotFoundHandler(e) {
    const contact = e.detail.formSubmission?.delegate?.element?.querySelector('.contact')
    if (contact && e.detail?.fetchResponse?.response?.status === 404) {
      const error = contact.querySelector('.contact-email-delete-error');
      error.style.display = 'block';
      error.querySelector('.error-msg').textContent = 'Not Found';
    }
  }
}