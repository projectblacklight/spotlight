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
      $("#page_" + data[i]['id'] + "_weight").val(weight);
      weight++;
      if(data[i]['children']){
        var children = data[i]['children'];
        for(var child in children){
          $("#page_" + children[child]['id'] + "_weight").val(weight);
          weight++;
        }
      }
    }
  });
}