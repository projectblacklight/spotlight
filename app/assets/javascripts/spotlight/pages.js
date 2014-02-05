// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Spotlight.onLoad(function() {
  // Initialize Nestable for nested pages
  $('#nested-pages.about_page_admin').nestable({maxDepth: 1});
  $('#nested-pages.feature_page_admin').nestable({maxDepth: 2, expandBtnHTML: "", collapseBtnHTML: ""});
  // Handle weighting the pages and their children.
  updatePageWeightsAndRelationships();
});

function updatePageWeightsAndRelationships(){
  $('#nested-pages').on('change',function(){
    var data = $(this).nestable('serialize')
    var weight = 0;
    for(var i in data){
      var parent_id = data[i]['id'];
      //exhibit_feature_pages_attributes_1_weight
      weight_field(parent_id).val(weight);
      weight++;
      if(data[i]['children']){
        var children = data[i]['children'];
        for(var child in children){
          weight_field(children[child]['id']).val(weight);
          weight++;
          parent_page_field(children[child]['id']).val(parent_id)
        }
      }else{
        parent_page_field(parent_id).val("")
      }
    }
  });
}

function weight_field(id) {
  return $("input[data-action=weight_"+id+"]");
}
function parent_page_field(id){
  return $("input[data-action=parent_page_" + id + "]")
}