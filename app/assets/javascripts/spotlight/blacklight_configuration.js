Spotlight.onLoad(function() {
  // Initialize Nestable for nested pages
  $('#nested-fields .metadata_fields').nestable({maxDepth: 1, listNodeName: "tbody", itemNodeName: "tr", expandBtnHTML: "", collapseBtnHTML: "" });
  $('#nested-fields.facet_fields').nestable({maxDepth: 1});

  // Handle weighting the pages and their children.
  updateWeightsAndRelationships($('#nested-fields .metadata_fields'));
  updateWeightsAndRelationships($('#nested-fields.facet_fields'));
});
