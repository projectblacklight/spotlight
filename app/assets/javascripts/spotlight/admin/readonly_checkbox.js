Spotlight.onLoad(function() {
  // Don't allow unchecking of checkboxes with the data-readonly attribute 
  $("input[type='checkbox'][data-readonly]").on("click", function(event) {
    event.preventDefault();
  });
});
