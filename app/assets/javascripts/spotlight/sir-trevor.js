(function ($){

  SirTrevor.BlockControl.prototype.render = function() {
    this.$el.html('<span class="st-icon st-icon-'+ _.result(this.block_type, "type") + '">'+ _.result(this.block_type, 'icon_name') +'</span>' + _.result(this.block_type, 'title'));
    return this;
  };
})(jQuery);
