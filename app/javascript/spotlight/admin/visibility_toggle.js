// Visibility toggle for items in an exhibit, based on Blacklight's bookmark toggle
// See: https://github.com/projectblacklight/blacklight/blob/main/app/javascript/blacklight/bookmark_toggle.js

import CheckboxSubmit from 'checkbox_submit'

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
