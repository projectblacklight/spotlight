// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Spotlight.onLoad(function() {
  expandAddButton();
  // Initialize Nestable for nested pages
  $('#nested-pages.about_pages_admin').nestable({maxDepth: 1});
  $('#nested-pages.feature_pages_admin').nestable({maxDepth: 2, expandBtnHTML: "", collapseBtnHTML: ""});
  $('#nested-pages.search_admin').nestable({maxDepth: 1});
  $('.contacts_admin').nestable({maxDepth: 1});
  // Handle weighting the pages and their children.
  updateWeightsAndRelationships($('#nested-pages'));
  updateWeightsAndRelationships($('.contacts_admin'));

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

    $('.slideshow-indicators li').on('click', function() {
      $(this).closest('.slideshow').find('li.active').removeClass('active');
      $(this).addClass('active');
    });
});

Spotlight.onLoad(function(){
  
  SirTrevor.setDefaults({
    uploadUrl: $('[data-attachment-endpoint]').data('attachment-endpoint')
  });
  var instances = $('.sir-trevor-area'),
      l = instances.length, instance;

  while (l--) {
    instance = $(instances[l]);
    new SirTrevor.Editor({ el: instance });
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
function addButtonElement(){
  return $("[data-expanded-add-button]");
}
function expandAddButton(){
  addButtonElement().each(function(){
    var button = $(this);
    var target = $(button.data('field-target'));
    var save =  $("input[type='submit']", target);
    var input = $("input[type='text']", target);
    var width = button.outerWidth();
    var speed = 450;
    // Animate button open when the mouse enters or
    // the button is given focus (i.e. clicked/tabbed)
    button.on("mouseenter focus", function(){
      if(button.outerWidth() <= (width + 5)) {
        $(this).animate(
          {width: '425px'}, speed, function(){
            target.show(0, function(){
              input.focus(); 
            });
          }
        )
      }
    });
    // Don't allow for blank titles
    save.on('click', function(){
      if ($.trim(input.val()) == "") {
        return false;
      }
    });
    $.each([input, save, button], function(){
      $(this).on("blur", function(){
        // Give a small timeout so that the 
        // button doesn't snap back right away.
        // This is necessary to let certain browsers
        // (e.g. Firefox) have enough time to submit the form.
        setTimeout(function(){
          // Unless the parent button or the save button is focussed
          if( !input.is(':focus') && !button.is(':focus') && !save.is(':focus') ) {
            // Hide the input/save button and animate the button closed
            target.hide();
            button.animate({width: width + 'px'}, speed);
          }
        }, 100);
      });
    });
  });
}
