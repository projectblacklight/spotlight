export default class {
  connect() {
    // Don't allow unchecking of checkboxes with the data-readonly attribute 
    document.querySelectorAll("input[type='checkbox'][data-readonly]").forEach(function(el) {
      el.addEventListener("click", function(event) {
        event.preventDefault();
      })
    })
  }
}
