(function ($){
  SirTrevor.BlockMixins.Autocompleteable = {
    mixinName: "Autocompleteable",
    preload: true,

    initializeAutocompleteable: function() {
      this.on("onRender", this.addAutocompletetoSirTrevorForm);

      if (this['autocomplete_url'] === undefined) {
        this.autocomplete_url = function() { return $('form[data-autocomplete-url]').data('autocomplete-url').replace("%25QUERY", "%QUERY"); };
      }

      if (this['transform_autocomplete_results'] === undefined) {
        this.transform_autocomplete_results = (val) => val
      }

      if (this['autocomplete_control'] === undefined) {
        this.autocomplete_control = function() { return `<input type="text" class="st-input-string form-control item-input-field" data-twitter-typeahead="true" placeholder="${i18n.t("blocks:autocompleteable:placeholder")}"/>` };
      }

      if (this['bloodhoundOptions'] === undefined) {
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

    addAutocompletetoSirTrevorForm: function() {
      $('[data-twitter-typeahead]', this.inner).spotlightSearchTypeAhead({bloodhound: this.bloodhound(), template: this.autocomplete_template}).on('typeahead:selected typeahead:autocompleted', this.autocompletedHandler()).on( 'focus', function() {
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
      var results = new Bloodhound(Object.assign({
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
