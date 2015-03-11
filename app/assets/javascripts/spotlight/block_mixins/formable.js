(function ($){
  SirTrevor.BlockMixins.Formable = {
    mixinName: "Formable",
    preload: true,

    initializeFormable: function() {
      
      if (_.isUndefined(this['afterLoadData'])) {
        this['afterLoadData'] = function(data) { };
      }
    },
    
    formId: function(id) {
      return this.blockID + "_" + id;
    },

    _serializeData: function() {
      
      var data = this.$(":input,textarea,select").not(':input:radio').serializeJSON();

      this.$(':input:radio:checked').each(function(index, input) {
        var key = $(input).data('key') || input.getAttribute('name');

        if (!key.match("\\[")) {
          data[key] = $(input).val();
        }
      });

      /* Simple to start. Add conditions later */
      if (this.hasTextBlock()) {
        data.text = this.getTextBlockHTML();
        if (data.text.length > 0 && this.options.convertToMarkdown) {
          data.text = stToMarkdown(data.text, this.type);
        }
      }

      return data;
    },
    
    loadData: function(data){
      if (this.hasTextBlock()) {
        this.getTextBlock().html(SirTrevor.toHTML(data.text, this.type));
      }
      this.loadFormDataByKey(data);
      this.afterLoadData(data);
    },
    
    loadFormDataByKey: function(data) {
      this.$(':input').not('button,:input[type=hidden]').each(function(index, input) {
        var key = $(input).data('key') || input.getAttribute('name');

        if (key) {
        
          if (key.match("\\[\\]$")) {
            key = key.replace("[]", "");
          }
          
          // by wrapping it in an array, this'll "just work" for radio and checkbox fields too
          var input_data = data[key];

          if (!(input_data instanceof Array)) {
            input_data = [input_data];
          }
          $(this).val(input_data);
        }
      });
    },
  },
  

  SirTrevor.Block.prototype.availableMixins.push("formable");
})(jQuery);
