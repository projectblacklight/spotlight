// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Spotlight.onLoad(function() {
  // Initialize Nestable for nested pages
  $('#nested-pages.about_page_admin').nestable({maxDepth: 1});
  $('#nested-pages.feature_page_admin').nestable({maxDepth: 2, expandBtnHTML: "", collapseBtnHTML: ""});
  $('#nested-pages.search_admin').nestable({maxDepth: 1});
  // Handle weighting the pages and their children.
  updateWeightsAndRelationships($('#nested-pages'));

   $.each($('.dd-handle'), function(k, el){
      var height;
      if ($(el).next('.dd3-content').length > 0) {
        height = $(el).next('.dd3-content').outerHeight();
      } else {
        height = $(el).closest(".dd-item").outerHeight();
      }
      $(el).css('height', height);
    });

    SirTrevor.EventBus.on('block:create:new', addTitleToSirTrevorBlock);
    SirTrevor.EventBus.on('block:create:existing', addTitleToSirTrevorBlock);
});

function addTitleToSirTrevorBlock(block){
  block.$inner.append("<div class='st-title'>" + block.title() + "</div>");
};

function updateWeightsAndRelationships(selector){
  $.each(selector, function() {
    $(this).on('change',function(){
      var data = $(this).nestable('serialize')
      var weight = 0;
      for(var i in data){
        var parent_id = data[i]['id'];
        parent_node = findNode(parent_id)
        setWeight(parent_node, weight++);
        if(data[i]['children']){
          var children = data[i]['children'];
          for(var child in children){
            var id = children[child]['id']
            child_node = findNode(id);
            setWeight(child_node, weight++);
            setParent(child_node, parent_id);
          }
        } else {
          setParent(parent_node, "");
        }
      }
    });
  });
}

function findNode(id) {
  return $("[data-id="+id+"]");
}

function setWeight(node, weight) {
  weight_field(node).val(weight);
}

function setParent(node, parent_id) {
  parent_page_field(node).val(parent_id);
}

/* find the input element with data-property="weight" that is nested under the given node */
function weight_field(node) {
  return find_property(node, "weight");
}

/* find the input element with data-property="parent_page" that is nested under the given node */
function parent_page_field(node){
  return find_property(node, "parent_page");
}

function find_property(node, property) {
  return node.find("input[data-property=" + property + "]");
 }
