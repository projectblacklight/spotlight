(function ($){
  SirTrevor.BlockMixins.Titleable = {
    mixinName: "Titleable",

    initializeTitleable: function() {
      this.$inner.append("<div class='st-title'>" + this.title() + "</div>");
    },
  }
  
  SirTrevor.Block.prototype.availableMixins.push("titleable");
  SirTrevor.Block.prototype.titleable = true;
})(jQuery);
