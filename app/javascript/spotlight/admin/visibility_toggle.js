// Blacklight's BookmarkToggle is doing the real work, this only adds/removes the "blacklight-private" class.
const VisibilityToggle = (e) => {
  if (e.target.matches('[data-checkboxsubmit-target="checkbox"]')) {
    const form = e.target.closest('form')
    if (form) {
      // Add/remove the "private" label to the document row when visibility is toggled
      const docRow = form.closest('tr')
      if (docRow) docRow.classList.toggle('blacklight-private')
    }
  }
}
document.addEventListener('click', VisibilityToggle)
export default VisibilityToggle
