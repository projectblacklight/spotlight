
(function( global ) {
  var Module = (function() {
    var nestableSelector = '[data-behavior="nestable"]';
    return {
      init: function(selector){

        $(selector || nestableSelector).each(function(){
          $(this).nestable($(this).data());
          updateWeightsAndRelationships($(this));
        });
      }
    };
    function updateWeightsAndRelationships(nestedList){
      nestedList.on('change', function(event){
        var container = $(event.currentTarget);
        var data = $(this).nestable('serialize');
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
  })();

  global.SpotlightNestable = Module;

})( this );
