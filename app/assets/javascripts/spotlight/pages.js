// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Spotlight.onLoad(function() {
  // Initialize Nestable for nested pages
  $('#nested-pages.about_pages_admin').nestable({maxDepth: 1});
  $('#nested-pages.feature_pages_admin').nestable({maxDepth: 2, expandBtnHTML: "", collapseBtnHTML: ""});
  $('#nested-pages.search_admin').nestable({maxDepth: 1});
  $('.contacts_admin').nestable({maxDepth: 1});
  // Handle weighting the pages and their children.
  updateWeightsAndRelationships($('#nested-pages'));
  updateWeightsAndRelationships($('.contacts_admin'));

  SirTrevor.EventBus.on('block:create:new', addTitleToSirTrevorBlock);
  SirTrevor.EventBus.on('block:create:existing', addTitleToSirTrevorBlock);

  $('.slideshow-indicators li').on('click', function() {
    $(this).closest('.slideshow').find('li.active').removeClass('active');
    $(this).addClass('active');
  });
});
var x,y;

Spotlight.onLoad(function(){
  
  SirTrevor.setDefaults({
    uploadUrl: $('[data-attachment-endpoint]').data('attachment-endpoint')
  });
  var instances = $('.sir-trevor-area'),
      l = instances.length, instance;

  while (l--) {
    instance = $(instances[l]);
    var editor = new SirTrevor.Editor({
      el: instance,
      onEditorRender: function() {
        serializeObservedForms(observedForms());
      },
      blockTypeLimits: {
        "SearchResults": 1
      }
    });
    
    function checkBlockTypeLimitOnAdd(block) {
      var control = editor.$wrapper.find("a[data-type='" + block.blockCSSClass() + "']");
      
      control.toggleClass("disabled", !editor._canAddBlockType(block.class()));
    }

    function checkBlockTypeLimitOnRemove() {
      // we don't know what type of block was removed.. So, try them all.
      
      $.each(editor.blockTypes, function(type) {
        var control = editor.$wrapper.find("a[data-type='" + _.underscored(type) + "']");
        control.toggleClass("disabled", !editor._canAddBlockType(type));
      });
    }
    
    x = editor;

    SirTrevor.EventBus.on('block:create:new', checkBlockTypeLimitOnAdd);
    SirTrevor.EventBus.on('block:create:existing', checkBlockTypeLimitOnAdd);
    SirTrevor.EventBus.on('block:remove', checkBlockTypeLimitOnRemove);
    
  }

});


function addTitleToSirTrevorBlock(block){
  block.$inner.append("<div class='st-title'>" + block.title() + "</div>");
};

function updateWeightsAndRelationships(selector){
  $.each(selector, function() {
    $(this).on('change', function(event){
      // Scope to a container because we may have two orderable sections on the page (e.g. About page has pages and contacts)
      container = $(event.currentTarget);
      var data = $(this).nestable('serialize')
      var weight = 0;
      for(var i in data){
        var parent_id = data[i]['id'];
        parent_node = findNode(parent_id, container);
        setWeight(parent_node, weight++);
        if(data[i]['children']){
          var children = data[i]['children'];
          for(var child in children){
            var id = children[child]['id']
            child_node = findNode(id, container);
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

function findNode(id, container) {
  return container.find("[data-id="+id+"]");
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
