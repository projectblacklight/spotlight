/*
* SerializedForm is built as a singleton. It needs to be able to
* handle instantiation from multiple sources, and use the [data-form-observer]
* as global state object.
*/

// Per-form state (replaces jQuery's .data() storage)
const formState = new WeakMap();

function getState(form) {
  if (!formState.has(form)) {
    formState.set(form, {});
  }
  return formState.get(form);
}

// Do custom serialization of the sir-trevor form data. This needs to be a
// passed in argument for comparison later on.
function formSerialization(form) {
  var params = new URLSearchParams();
  for (const element of form.elements) {
    if (!element.name || element.disabled) continue;
    const type = (element.type || '').toLowerCase();
    if (type === 'file' || type === 'submit' || type === 'button' ||
        type === 'reset' || type === 'image') continue;
    if ((type === 'checkbox' || type === 'radio') && !element.checked) continue;
    params.append(element.name, element.value);
  }

  var content_editable = [];
  var i = 0;
  form.querySelectorAll("[contenteditable='true']").forEach(element => {
    content_editable.push('&contenteditable_' + i + '=' + element.textContent);
    i++;
  });
  return params.toString() + content_editable.join('');
}

// Unbind observing form on submit (which we have to do because of turbolinks)
function bindObservedFormSubmit(form) {
  var state = getState(form);
  if (state.submitBound) return;
  state.submitBound = true;
  form.addEventListener('submit', () => {
    getState(form).beingSubmitted = true;
  });
}

export const SerializedForm = {
  // Store form serialization in state and bind submit handlers
  init() {
    document.querySelectorAll('[data-form-observer]').forEach(form => {
      getState(form).serialized = formSerialization(form);
      bindObservedFormSubmit(form);
    });
    return this;
  },

  // Check all observed forms on page for status change
  observedFormsStatusHasChanged() {
    return Array.from(document.querySelectorAll('[data-form-observer]')).some(form => {
      var state = getState(form);
      if (state.beingSubmitted) return false;
      return state.serialized !== formSerialization(form);
    });
  }
};

var UNSAVED_CHANGES_MESSAGE = "You have unsaved changes. Are you sure you want to leave this page?";

// Don't handle the same event twice #turbolinks
function handleNavigationEvent(event) {
  if (event.handled === true) return;
  if (!SerializedForm.observedFormsStatusHasChanged()) return;
  event.handled = true;

  // There are variations in how Webkit browsers may handle this:
  // https://developer.mozilla.org/en-US/docs/Web/Events/beforeunload
  if (event.type === 'beforeunload') {
    event.preventDefault();
    event.returnValue = UNSAVED_CHANGES_MESSAGE;
    return UNSAVED_CHANGES_MESSAGE;
  } else {
    if (!confirm(UNSAVED_CHANGES_MESSAGE)) {
      event.preventDefault();
    }
  }
}

export default class {
  connect() {
    // Instantiate the singleton SerializedForm plugin
    SerializedForm.init();
    window.addEventListener('beforeunload', handleNavigationEvent);
    document.addEventListener('page:before-change', handleNavigationEvent);
    document.addEventListener('turbolinks:before-visit', handleNavigationEvent);
    document.addEventListener('turbo:before-visit', handleNavigationEvent);
  }
}
