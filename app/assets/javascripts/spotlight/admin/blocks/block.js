(function ($){
  Spotlight.Block = SirTrevor.Block.extend({
    formable: true,
    editorHTML: function() {
      return _.template(this.template)(this);
    },
    beforeBlockRender: function() {
      this.availableMixins.forEach(function(mixin) {
        if (this[mixin] && SirTrevor.BlockMixins[this.capitalize(mixin)].preload) {
          this.withMixin(SirTrevor.BlockMixins[this.capitalize(mixin)]);
        }
      }, this);
    },
    $instance: function() { return $('#' + this.instanceID); },
    capitalize: function(string) {
      return string.charAt(0).toUpperCase() + string.substring(1).toLowerCase();
    }
  })
})(jQuery);
