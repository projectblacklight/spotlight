SirTrevor.BlockControls.prototype.initialize = function() {
  var groups = {};
  for(var block_type in this.available_types) {
    if (SirTrevor.Blocks.hasOwnProperty(block_type)) {
      var block_control = new SirTrevor.BlockControl(block_type, this.instance_scope);
      if (block_control.can_be_rendered) {
        var blockGroup;

        if ($.isFunction(SirTrevor.Blocks[block_type].prototype.blockGroup)) {
          blockGroup = SirTrevor.Blocks[block_type].prototype.blockGroup();
        } else {
          blockGroup = SirTrevor.Blocks[block_type].prototype.blockGroup;
        }
        
        groups[blockGroup] = groups[blockGroup] || [];
        groups[blockGroup].push(block_control.render().$el);
      }
    }
  }
  for(groupKey in groups) {
    var group   = groups[groupKey];
    if(groupKey == 'undefined' || groupKey === undefined) {
      groupKey = i18n.t("blocks:group:undefined");
    }
    var groupEl = $("<div class='st-controls-group'><div class='st-group-control-label'>" + groupKey + "</div></div>");
    $.each(group, function(){
      groupEl.append($(this));
    });
    this.$el.append(groupEl);
  }

  this.$el.delegate('.st-block-control', 'click', this.handleControlButtonClick);
};