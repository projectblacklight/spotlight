(function ($){
  Spotlight.Block = SirTrevor.Block.extend({
    editorHTML: function() {
      return this.template(this);
    },
    formId: function(id) {
      return this.blockID + "_" + id;
    },
    onBlockRender: function() {
      addAutocompletetoSirTrevorForm();
    },
    toData: function() {
      var data = {};


      /* Simple to start. Add conditions later */
      if (this.hasTextBlock()) {
        var content = this.getTextBlock().html();
        if (content.length > 0) {
          data.text = SirTrevor.toMarkdown(content, this.type);
        } else {
          data.text = "";
        }
      }

      // Add any inputs to the data attr
      var inputs = this.$(':input').
          not('.st-paste-block').
          not('button').
          not(':input:checkbox,:input:radio').
          add(this.$(':input:checkbox:checked')).
          add(this.$(':input:radio:checked')).
          add(this.$('select'))

      // unchecked checkboxes
      this.$(':input:checkbox,:input:radio').not(':input:checkbox:checked').not(':input:radio:checked').each(function(index,input) {
        var key = $(input).data('key') || input.getAttribute('name');
        if (key) {
          data[key] = null;
        }
      });

      if(inputs.length > 0) {
        inputs.each(function(index,input){
          var key = $(input).data('key') || input.getAttribute('name');
          if (key) {
            if($(input).is(':checkbox') && $(input).val() == "true") {
              data[key] = true;
            } else {
              data[key] = $(input).val();
            }
          }
        });
      }

      // Set
      if(!_.isEmpty(data)) {
        this.setData(data);
      }
    },

    loadFormDataByKey: function(data) {
      this.$(':input').not('button').each(function(index, input) {
        var key = $(input).data('key') || input.getAttribute('name');
        // by wrapping it in an array, it'll "just work" for radio and checkbox fields too
        $(this).val([data[key]]);
      });
    },

    loadData: function(data){
      if (this.hasTextBlock()) {
        this.getTextBlock().html(SirTrevor.toHTML(data.text, this.type));
      }
      this.loadFormDataByKey(data);
      this.afterLoadData(data);
    },

    afterLoadData: function(data) { }

  });


  SirTrevor.BlockControl.prototype.render = function() {
    this.$el.html('<span class="st-icon st-icon-'+ _.result(this.block_type, "type") + '">'+ _.result(this.block_type, 'icon_name') +'</span>' + _.result(this.block_type, 'title'));
    return this;
  };
})(jQuery);
