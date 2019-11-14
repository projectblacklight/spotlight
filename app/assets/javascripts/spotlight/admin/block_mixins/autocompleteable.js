(function ($){
  SirTrevor.BlockMixins.Autocompleteable = {
    mixinName: "Autocompleteable",
    preload: true,

    initializeAutocompleteable: function() {
      this.on("onRender", this.addAutocompletetoSirTrevorForm);

      if (_.isUndefined(this['autocomplete_url'])) {
        this.autocomplete_url = function() { return $('form[data-autocomplete-url]').data('autocomplete-url').replace("%25QUERY", "%QUERY"); };
      }

      if (_.isUndefined(this['autocomplete_template'])) {
        this.autocomplete_url = function() { return '<div class="autocomplete-item{{#if private}} blacklight-private{{/if}}">{{#if thumbnail}}<div class="document-thumbnail"><img class="img-thumbnail" src="{{thumbnail}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' };
      }

      if (_.isUndefined(this['transform_autocomplete_results'])) {
        this.transform_autocomplete_results = _.identity;
      }

      if (_.isUndefined(this['bloodhoundOptions'])) {
        this.bloodhoundOptions = function() {
          return {
            remote: {
              url: this.autocomplete_url(),
              filter: this.transform_autocomplete_results
            }
          };
        };
      }
    },

    autocomplete_control: function() {
      return '<input type="text" class="st-input-string form-control item-input-field" data-twitter-typeahead="true" placeholder="<%= i18n.t("blocks:autocompleteable:placeholder")%>"/>';
    },

    addAutocompletetoSirTrevorForm: function() {
      $('[data-twitter-typeahead]', this.inner).spotlightSearchTypeAhead({bloodhound: this.bloodhound(), template: this.autocomplete_template()}).on('typeahead:selected typeahead:autocompleted', this.autocompletedHandler()).on( 'focus', function() {
        if($(this).val() === '') {
          $(this).data().ttTypeahead.input.trigger('queryChanged', '');
        }
      });
    },

    autocompletedHandler: function(e, data) {
      var context = this;

      return function(e, data) {
        $(this).typeahead("val", "");
        $(this).val("");

        context.createItemPanel($.extend(data, {display: "true"}));
      }
    },

    bloodhound: function() {
      var block = this;
      var results = new Bloodhound(_.extend({
        datumTokenizer: function(d) {
          return Bloodhound.tokenizers.whitespace(d.title);
        },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        limit: 100,
      }, block.bloodhoundOptions()));
      results.initialize();
      return results;
    },
  },


  SirTrevor.Block.prototype.availableMixins.push("autocompleteable");
})(jQuery);
