export default class {
  connect() {
    // Add Select/Deselect all input behavior
    this.addCheckboxToggleBehavior();
    this.addEnableToggleBehavior();
  }
  
  // Add Select/Deselect all behavior for metadata field names for a given view e.g. Item details. 
  addCheckboxToggleBehavior() {
    $("[data-behavior='metadata-select']").each(function(){
      var selectCheckbox = $(this);
      var parentCell = selectCheckbox.parents("th");
      var table = parentCell.closest("table");
      var columnRows = $("tr td:nth-child(" + (parentCell.index() + 1) + ")", table);
      var checkboxes = $("input[type='checkbox']", columnRows);
      updateSelectAllInput(selectCheckbox, columnRows);
      // Add the check/uncheck behavior to the select/deselect all checkbox
      selectCheckbox.on('click', function(e){
        var allChecked = allCheckboxesChecked(columnRows);
        columnRows.each(function(){
          $("input[type='checkbox']", $(this)).prop('checked', !allChecked);
        });
      });
      // When a single checkbox is selected/unselected, the "All" checkbox should be updated accordingly.
      checkboxes.each(function(){
        $(this).on('change', function(){
          updateSelectAllInput(selectCheckbox, columnRows);
        });
      }); 
    });

    // Check number of checkboxes against the number of checked
    // checkboxes to determine if all of them are checked or not
    function allCheckboxesChecked(elements) {
      return ($("input[type='checkbox']", elements).length == $("input[type='checkbox']:checked", elements).length)
    }

    // Check or uncheck the "All" checkbox for each view column, e.g. Item details, List, etc.
    function updateSelectAllInput(checkbox, elements) {
      if ( allCheckboxesChecked(elements) ) {
        checkbox.prop('checked', true);
      } else {
        checkbox.prop('checked', false);
      }
    }
  }
    
  addEnableToggleBehavior() {
    $("[data-behavior='enable-feature']").each(function(){
      var checkbox = $(this);
      var target = $($(this).data('target'));

      checkbox.on('change', function() {
        if ($(this).is(':checked')) {
          target.find('input:checkbox').not("[data-behavior='enable-feature']").prop('checked', true).attr('disabled', false);
        } else {
          target.find('input:checkbox').not("[data-behavior='enable-feature']").prop('checked', false).attr('disabled', true);
        }
      });
    });
  }
}
