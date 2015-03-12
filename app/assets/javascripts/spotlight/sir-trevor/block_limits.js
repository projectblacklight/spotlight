Spotlight.BlockLimits = function(editor) {
  this.editor = editor;

}

Spotlight.BlockLimits.prototype.enforceLimits = function() {
  this.addEditorCallbacks();
  this.checkGlobalBlockTypeLimit()();
}

Spotlight.BlockLimits.prototype.addEditorCallbacks = function() {
  SirTrevor.EventBus.on('block:create:new', this.checkBlockTypeLimitOnAdd());
  SirTrevor.EventBus.on('block:remove', this.checkGlobalBlockTypeLimit());
}

Spotlight.BlockLimits.prototype.checkBlockTypeLimitOnAdd = function() {
  var editor = this.editor;

  return function(block) {
    var control = editor.$outer.find("a[data-type='" + block.blockCSSClass() + "']");

    control.toggleClass("disabled", !editor.block_manager.canAddBlockType(block.class()));
  }
}

Spotlight.BlockLimits.prototype.checkGlobalBlockTypeLimit = function() {
  // we don't know what type of block was created or removed.. So, try them all.
  var editor = this.editor;

  return function() {
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
}
