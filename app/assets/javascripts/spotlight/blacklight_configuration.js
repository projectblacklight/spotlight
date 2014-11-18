Spotlight.onLoad(function() {
  // Add Select/Deselect all button behavior
  addCheckboxToggleBehavior();

  $("[data-in-place-edit-target]").on('click.inplaceedit', function() {
    var $input = $(this).find('input');
    var $label = $(this).find($(this).data('in-place-edit-target'));

    // hide the edit-in-place affordance icon while in edit mode
    $(this).addClass('hide-edit-icon');
    $label.hide();
    $input.val($label.text());
    $input.attr('type', 'text');
    $input.select();
    $input.focus();

    $input.on('keypress', function(e) {
      if(e.which == 13) {
        $input.trigger('blur.inplaceedit');
        return false;
      }
    });

    $input.on('blur.inplaceedit', function() {
      $label.text($input.val());
      $label.show();
      $input.attr('type', 'hidden');
      // when leaving edit mode, should no longer hide edit-in-place affordance icon
      $("[data-in-place-edit-target]").removeClass('hide-edit-icon');

      return false;
    });

    return false;
  });
});

// Add Select/Deselect all button behavior
function addCheckboxToggleBehavior() {
  $("[data-behavior='metadata-select']").each(function(){
    var button = $(this)
    var parentCell = button.parents("th");
    var table = parentCell.closest("table");
    var columnRows = $("tr td:nth-child(" + (parentCell.index() + 1) + ")", table);
    var checkboxes = $("input[type='checkbox']", columnRows);
    swapSelectAllButtonText(button, columnRows);
    // Add the check/uncheck behavior to the button
    // and swap the button text if necessary
    button.on('click', function(e){
      e.preventDefault();
      var allChecked = allCheckboxesChecked(columnRows);
      columnRows.each(function(){
        $("input[type='checkbox']", $(this)).prop('checked', !allChecked);
        swapSelectAllButtonText(button, columnRows);
      });
    });
    // Swap button text when a checkbox value changes
    checkboxes.each(function(){
      $(this).on('change', function(){
        swapSelectAllButtonText(button, columnRows);
      });
    });
  });
  // Check number of checkboxes against the number of checked
  // checkboxes to determine if all of them are checked or not
  function allCheckboxesChecked(elements) {
    return ($("input[type='checkbox']", elements).length == $("input[type='checkbox']:checked", elements).length)
  }
  // Swap the button text to "Deselect all"
  // when all the checkboxes are checked and
  // "Select all" when any are unchecked
  function swapSelectAllButtonText(button, elements) {
    if ( allCheckboxesChecked(elements) ) {
      button.text(button.data('deselect-text'));
    } else {
      button.text(button.data('select-text'));
    }
  }
}