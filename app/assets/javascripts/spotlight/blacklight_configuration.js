Spotlight.onLoad(function() {
  // Initialize Nestable for nested pages
  $('#nested-fields .metadata_fields').nestable({maxDepth: 1, listNodeName: "tbody", itemNodeName: "tr", expandBtnHTML: "", collapseBtnHTML: "" });
  $('#nested-fields.facet_fields').nestable({maxDepth: 1});

  // Handle weighting the pages and their children.
  updateWeightsAndRelationships($('#nested-fields .metadata_fields'));
  updateWeightsAndRelationships($('#nested-fields.facet_fields'));

  $('.field-label').on('click.inplaceedit', function() {
    var $input = $(this).next('input');
    var $label = $(this);

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

      return false;
    });

    return false;
  });
});
