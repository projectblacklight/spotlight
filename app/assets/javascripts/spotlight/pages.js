// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Spotlight.onLoad(function() {
  // Initialize Nestable for nested pages
  $('#nested-pages.about_page_admin').nestable({maxDepth: 1});
  $('#nested-pages.feature_page_admin').nestable({maxDepth: 1}); // Change to maxDepth: 2 for single child relationship
  // Handle weighting the pages and their children.
  featurePagesWeighting();
});

function featurePagesWeighting(){
  $('#nested-pages').on('change',function(){
    var data = $(this).nestable('serialize')
    var weight = 0;
    for(var i in data){
      //exhibit_feature_pages_attributes_1_weight
      weight_field(data[i]['id']).val(weight);
      weight++;
      if(data[i]['children']){
        var children = data[i]['children'];
        for(var child in children){
          weight_field(children[child]['id']).val(weight);
          weight++;
        }
      }
    }
  });
}

function weight_field(id) {
  return $("input[data-action=weight_"+id+"]");
}

