/*
NOTE: this is copied & adapted from BL8's checkbox_submit.js in order to have
it accessible in a BL7-based spotlight. Once we drop support for BL7, this file
can be deleted and we can change visibility_toggle.es6 to import CheckboxSubmit
from Blacklight.

See https://github.com/projectblacklight/blacklight/blob/main/app/javascript/blacklight/checkbox_submit.js
*/
export default class CheckboxSubmit {
  constructor(form) {
    this.form = form
  }

  async clicked(evt) {
    this.spanTarget.innerHTML = this.form.getAttribute('data-inprogress')
    this.labelTarget.setAttribute('disabled', 'disabled');
    this.checkboxTarget.setAttribute('disabled', 'disabled');
    const csrfMeta = document.querySelector('meta[name=csrf-token]')
    const response = await fetch(this.formTarget.getAttribute('action'), {
      body: new FormData(this.formTarget),
      method: this.formTarget.getAttribute('method').toUpperCase(),
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': csrfMeta ? csrfMeta.content : ''
      }
    })
    this.labelTarget.removeAttribute('disabled')
    this.checkboxTarget.removeAttribute('disabled')
    if (response.ok) {
      this.updateStateFor(!this.checked)
      // Not used for our case in Spotlight (visibility toggle)
      // const json = await response.json()
      // document.querySelector('[data-role=bookmark-counter]').innerHTML = json.bookmarks.count
    } else {
      alert('Error')
    }
  }

  get checked() {
    return (this.form.querySelectorAll('input[name=_method][value=delete]').length != 0)
  }

  get formTarget() {
    return this.form
  }

  get labelTarget() {
    return this.form.querySelector('[data-checkboxsubmit-target="label"]')
  }

  get checkboxTarget() {
    return this.form.querySelector('[data-checkboxsubmit-target="checkbox"]')
  }

  get spanTarget() {
    return this.form.querySelector('[data-checkboxsubmit-target="span"]')
  }

  updateStateFor(state) {
    this.checkboxTarget.checked = state

    if (state) {
      this.labelTarget.classList.add('checked')
      //Set the Rails hidden field that fakes an HTTP verb
      //properly for current state action.
      this.formTarget.querySelector('input[name=_method]').value = 'delete'
      this.spanTarget.innerHTML = this.form.getAttribute('data-present')
    } else {
      this.labelTarget.classList.remove('checked')
      this.formTarget.querySelector('input[name=_method]').value = 'put'
      this.spanTarget.innerHTML = this.form.getAttribute('data-absent')
    }
  }
}
