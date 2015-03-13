(function ($){
  SirTrevor.PreviewButton = function() {
    this._ensureElement();
    this._bindFunctions();
  }

  SirTrevor.PreviewButton.prototype = Object.create(SirTrevor.BlockDeletion.prototype);

  SirTrevor.PreviewButton.prototype.attributes = {
    html: 'preview',
    'data-icon': 'preview'
  };

  SirTrevor.PreviewButton.prototype.className = 'st-block-ui-btn st-block-ui-btn--preview st-icon';

  SirTrevor.EditButton = function() {
    this._ensureElement();
    this._bindFunctions();
  }

  SirTrevor.EditButton.prototype = Object.create(SirTrevor.BlockDeletion.prototype);
  
  SirTrevor.EditButton.prototype.attributes = {
    html: 'edit',
    'data-icon': 'edit'
  };

  SirTrevor.EditButton.prototype.className = 'st-block-ui-btn st-block-ui-btn--edit st-icon';


  SirTrevor.BlockMixins.Previewable = {

    mixinName: "Previewable",

    initializePreviewable: function() {
      this.on("onRender", this.addPreviewButton);
      
      if (_.isUndefined(this['afterPreviewLoad'])) {
        this.afterPreviewLoad = function() { };
      }
    },

    addPreviewButton: function() {
      this._prependUIComponent(new SirTrevor.PreviewButton(), '.st-block-ui-btn--preview', this.previewHandler())
    },

    _prependUIComponent: function(component, className, callback) {
      this.$ui.prepend(component.render().$el);
      if (className && callback) {
        this.$ui.on('click', className, callback);
      }
    },
    
    previewButton: '<button class="st-block-ui-btn preview-btn"><%= i18n.t("blocks:previewable:title") %></button>',

    previewUrl: function(context) { return context.$el.closest('[data-preview-url]').data('preview-url'); },

    previewHandler: function() {
      var context = this;

      return function(event) {
        event.stopPropagation();
        var $btn = $(this);

        $btn.attr('disabled', 'disabled');

        $.post(context.previewUrl(context), { block: JSON.stringify(context.getData()) }, function(preview) {
          context.renderPreview(preview).insertAfter(context.$inner);
          context.$inner.hide();

          context.afterPreviewLoad();
        });
      }
    },

    renderPreview: function(preview) {
      var btn = new SirTrevor.EditButton().render().$el;
      btn.on('click', this.editHandler(btn));

      var widget_bar = $('<div class="st-block__ui" />').append(btn);

      var inner = $('<div class="preview clearfix st-block__inner">');

      return inner.append(preview).append(widget_bar);
    },

    editHandler: function(btn) {
      var context = this;
      var $btn = btn;

      return function(event) {
        event.stopPropagation();
        context.$inner.show();
        $(this).closest('.preview').remove();
        $btn.removeAttr('disabled');
      }
    },
  },
  

  SirTrevor.Block.prototype.availableMixins.push("previewable");
  SirTrevor.Block.prototype.previewable = true;
})(jQuery);
