// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
Spotlight.onLoad(function(){

  SirTrevor.BlockControls.prototype.initialize = function() {
    var groups = {};
    for(var block_type in this.available_types) {
      if (SirTrevor.Blocks.hasOwnProperty(block_type)) {
        var block_control = new SirTrevor.BlockControl(block_type, this.instance_scope);
        if (block_control.can_be_rendered) {
          var blockGroup = SirTrevor.Blocks[block_type].prototype.blockGroup;
          groups[blockGroup] = groups[blockGroup] || [];
          groups[blockGroup].push(block_control.render().$el);
        }
      }
    }
    for(groupKey in groups) {
      var group   = groups[groupKey];
      if(groupKey == 'undefined' || groupKey === undefined) {
        groupKey = "Standard widgets";
      }
      var groupEl = $("<div class='st-controls-group'><div class='st-group-control-label'>" + groupKey + "</div></div>");
      $.each(group, function(){
        groupEl.append($(this));
      });
      this.$el.append(groupEl);
    }

    this.$el.delegate('.st-block-control', 'click', this.handleControlButtonClick);
  };

  SirTrevor.setDefaults({
    uploadUrl: $('[data-attachment-endpoint]').data('attachment-endpoint')
  });

  var instance = $('.js-st-instance').first();

  if (instance.length) {

    function checkBlockTypeLimitOnAdd(block) {
      var control = editor.$outer.find("a[data-type='" + block.blockCSSClass() + "']");

      control.toggleClass("disabled", !editor._canAddBlockType(block.class()));
    }

    function checkGlobalBlockTypeLimit() {
      // we don't know what type of block was created or removed.. So, try them all.

      $.each(editor.block_manager.blockTypes, function(type) {
        var block_type = SirTrevor.Blocks[type].prototype;

        var control = editor.$outer.find(".st-block-control[data-type='" + block_type.type + "']");
        if (editor.block_manager._getBlockTypeLimit(type) < 0) {
          control.remove();
        } else {
          control.toggleClass("disabled", !editor.block_manager.canAddBlockType(type));
        }
      });
    }

    var editor = new SirTrevor.Editor({
      el: instance,
      onEditorRender: function() {
        serializeObservedForms(observedForms());
      },
      blockTypeLimits: {
        "SearchResults": 1,
        "Tweet": -1
      }
    });

    editor.mediator.on('block:create:new', checkBlockTypeLimitOnAdd);
    editor.mediator.on('block:remove', checkGlobalBlockTypeLimit);

    checkGlobalBlockTypeLimit();
  }
});
