(function ($){
  Spotlight.Block = SirTrevor.Block.extend({
    formable: true,
    editorHTML: function() {
      return _.template(this.template)(this);
    },
    beforeBlockRender: function() {
      this.availableMixins.forEach(function(mixin) {
        if (this[mixin] && SirTrevor.BlockMixins[_.capitalize(mixin)].preload) {
          this.withMixin(SirTrevor.BlockMixins[_.capitalize(mixin)]);
        }
      }, this);
    },
    $instance: function() { return $('#' + this.instanceID); }
  })
})(jQuery);
