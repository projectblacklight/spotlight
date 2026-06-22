/*
  Simple plugin add edit-in-place behavior
*/
export default class {
  connect() {
    document.querySelectorAll('[data-in-place-edit-target]').forEach(function(container) {
      var label = container.querySelector(container.dataset.inPlaceEditTarget);
      var input = container.querySelector(container.dataset.inPlaceEditFieldTarget);
      if (!label || !input) return;

      container.addEventListener('click', function(e) {
        // hide the edit-in-place affordance icon while in edit mode
        container.classList.add('hide-edit-icon');
        label.style.display = 'none';
        input.value = label.textContent;
        input.setAttribute('type', 'text');
        input.select();
        input.focus();
        e.preventDefault();
      });

      input.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
          input.blur();
          e.preventDefault();
        }
      });

      input.addEventListener('blur', function() {
        var value = input.value;

        if (value.trim().length == 0) {
          input.value = label.textContent;
        } else {
          label.textContent = value;
        }

        label.style.display = '';
        input.setAttribute('type', 'hidden');
        // when leaving edit mode, should no longer hide edit-in-place affordance icon
        document.querySelectorAll("[data-in-place-edit-target]").forEach(function(el) {
          el.classList.remove('hide-edit-icon');
        });
      });
    });

    document.querySelectorAll("[data-behavior='restore-default']").forEach(function(container) {
      var hidden = container.querySelector("[data-default-value]");
      var inPlaceEditContainer = container.querySelector("[data-in-place-edit-target]");
      var button = container.querySelector("[data-restore-default]");
      if (!hidden || !inPlaceEditContainer || !button) return;

      var value = container.querySelector(inPlaceEditContainer.dataset.inPlaceEditTarget);

      hidden.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
          hidden.blur();
          e.preventDefault();
        }
      });

      hidden.addEventListener('blur', function() {
        if (hidden.value == hidden.dataset.defaultValue) {
          button.classList.add('d-none');
        } else {
          button.classList.remove('d-none');
        }
      });

      button.addEventListener('click', function(e) {
        e.preventDefault();
        hidden.value = hidden.dataset.defaultValue;
        if (value) value.textContent = hidden.dataset.defaultValue;
        button.style.display = 'none';
      });
    });
  }
}
