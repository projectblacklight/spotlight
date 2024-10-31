import Core from 'spotlight/core'

Core.BlockLimits = function(editor) {
  this.editor = editor;
};

Core.BlockLimits.prototype.enforceLimits = function(editor) {
  this.addEditorCallbacks(editor);
  this.checkGlobalBlockTypeLimit()();
};

Core.BlockLimits.prototype.addEditorCallbacks = function(editor) {
  SirTrevor.EventBus.on('block:create:new', this.checkBlockTypeLimitOnAdd());
  SirTrevor.EventBus.on('block:remove', this.checkGlobalBlockTypeLimit());
};

Core.BlockLimits.prototype.checkBlockTypeLimitOnAdd = function() {
  var editor = this.editor;

  return function(block) {
    var control = $(".st-block-controls__button[data-type='" + block.type + "']", editor.blockControls.el);

    control.prop("disabled", !editor.blockManager.canCreateBlock(block.class()));
  };
};

Core.BlockLimits.prototype.checkGlobalBlockTypeLimit = function() {
  // we don't know what type of block was created or removed.. So, try them all.
  var editor = this.editor;

  return function() {
    $.each(editor.blockManager.blockTypes, function(i, type) {
      var block_type = SirTrevor.Blocks[type].prototype;

      var control = $(editor.blockControls.el).find(".st-block-controls__button[data-type='" + block_type.type + "']");
      control.prop("disabled", !editor.blockManager.canCreateBlock(type));
    });
  };
};
