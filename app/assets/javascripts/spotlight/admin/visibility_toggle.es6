// Visibility toggle for items in an exhibit, based on Blacklight's bookmark toggle
// See: https://github.com/projectblacklight/blacklight/blob/main/app/javascript/blacklight/bookmark_toggle.js

// This comes from checkbox_submit.es6; ES6 modules are available as UMD in the
// global scope. See: https://github.com/projectblacklight/spotlight/pull/2599
const CheckboxSubmit = spotlightAdminCheckbox_submit

const VisibilityToggle = (e) => {
  if (e.target.matches('[data-checkboxsubmit-target="checkbox"]')) {
    const form = e.target.closest('form')
    if (form) {
      new CheckboxSubmit(form).clicked(e)

      // Add/remove the "private" label to the document row when visibility is toggled
      const docRow = form.closest('tr')
      if (docRow) docRow.classList.toggle('blacklight-private')
    }
  }
}

VisibilityToggle.selector = 'form.visibility-toggle'

document.addEventListener('click', VisibilityToggle)

export default VisibilityToggle
