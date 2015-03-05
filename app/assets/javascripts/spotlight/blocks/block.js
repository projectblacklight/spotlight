(function ($){
  Spotlight.Block = SirTrevor.Block.extend({
    editorHTML: function() {
      return _.template(this.template)(this);
    },
    formId: function(id) {
      return this.blockID + "_" + id;
    },
    onBlockRender: function() {
      addAutocompletetoSirTrevorForm({ bloodhound: this.bloodhound});
    },
    bloodhound: function() {
      return undefined;
    },
    _serializeData: function() {
      var data = {};
      
      /* Simple to start. Add conditions later */
      if (this.hasTextBlock()) {
        data.text = this.getTextBlockHTML();
        if (data.text.length > 0 && this.options.convertToMarkdown) {
          data.text = stToMarkdown(data.text, this.type);
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

      return data;
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

    afterLoadData: function(data) { },

    caption_field_template: ['<option value="<%= field %>"><%= label %></option>'].join("\n"),

    loadCaptionField: function(){
      var block = this;
      var metadata_url = $('form[data-metadata-url]').data('metadata-url');
      var primary_caption_field = $('#' + this.formId(this.primary_field_key));
      var secondary_caption_field = $('#' + this.formId(this.secondary_field_key));
      var primary_caption_selected_value = primary_caption_field.data("select-after-ajax");
      var secondary_caption_selected_value = secondary_caption_field.data("select-after-ajax");
      $.ajax({
        accepts: "json",
        url: metadata_url
      }).success(function(data){
        // Only checking the primary caption field
        // Could check both but I'm not sure it's necessary
        if($("option", primary_caption_field).length == 2){
          var options = "";
          $.each(data, function(i, field){
            options += _.template(block.caption_field_template)(field);
          });

          primary_caption_field.append(options);
          secondary_caption_field.append(options);

          primary_caption_field.val([primary_caption_selected_value]);
          secondary_caption_field.val([secondary_caption_selected_value]);
          // re-serialize the form so the form observer
          // knows about the new drop down options.
          serializeFormStatus($('form[data-metadata-url]'));
        }
      });
    },

    addCaptionSelectFocus: function(){
      $("[data-behavior='item-caption-admin']").each(function(){
        var checkbox = $('input[type="checkbox"]', $(this));
        var select = $('select', $(this));
        checkbox.on('change', function(){
          if ( $(this).is(':checked') ) {
            select.focus();
          }
        });
        select.on('change', function(){
          checkbox.prop('checked', !($(this).val() == ""))
        });
      });
    }

  });


  SirTrevor.BlockControl.prototype.render = function() {
    this.$el.html('<span class="st-icon st-icon-'+ _.result(this.block_type, "type") + '">'+ _.result(this.block_type, 'icon_name') +'</span>' + _.result(this.block_type, 'title'));
    return this;
  };
})(jQuery);
