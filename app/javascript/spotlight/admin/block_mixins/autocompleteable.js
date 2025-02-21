import { fetchAutocompleteJSON } from 'spotlight/admin/search_typeahead';

(function ($){
  SirTrevor.BlockMixins.Autocompleteable = {
    mixinName: "Autocompleteable",
    preload: true,

    initializeAutocompleteable: function() {
      this.on("onRender", this.addAutocompletetoSirTrevorForm);

      if (this['autocomplete_url'] === undefined) {
        this.autocomplete_url = function() { return $('form[data-autocomplete-url]').data('autocomplete-url'); };
      }

      if (this['autocomplete_fetch'] === undefined) {
        this.autocomplete_fetch = this.fetchAutocompleteResults;
      }

      if (this['transform_autocomplete_results'] === undefined) {
        this.transform_autocomplete_results = (val) => val
      }

      if (this['highlight'] === undefined) {
        this.highlight = function(value) {
          if (!value) return '';
          const queryValue = this.getQueryValue().trim();
          return queryValue ? value.replace(new RegExp(queryValue, 'gi'), '<strong>$&</strong>') : value;
        }
      }

      if (this['autocomplete_control'] === undefined) {
        this.autocomplete_control = function() {
          const autocompleteID = this.autocompleteID();
          return `
          <auto-complete src="${this.autocomplete_url()}" for="${autocompleteID}-popup" fetch-on-empty>
            <input type="text" name="${autocompleteID}" placeholder="${i18n.t("blocks:autocompleteable:placeholder")}" data-default-typeahead>
            <ul id="${autocompleteID}-popup"></ul>
            <div id="${autocompleteID}-popup-feedback" class="visually-hidden"></div>
          </auto-complete>
        ` };
      }

      if (this['autocomplete_element_template'] === undefined) {
        this.autocomplete_element_template = function(item) {
          return `<li role="option" data-autocomplete-value="${item.id}">${this.autocomplete_template(item)}</li>`
        }
      }
    },

    queryTokenizer: function(query) {
      return query.trim().toLowerCase().split(/\s+/).filter(Boolean);
    },

    filterResults: function(data, query) {
      const queryStrings = this.queryTokenizer(query);
      return data.filter(item => {
        const lowerTitle = item.title.toLowerCase();
        return queryStrings.some(queryString => lowerTitle.includes(queryString));
      });
    },

    fetchAutocompleteResults: async function(url) {
      const result = await fetchAutocompleteJSON(url);
      const transformed = this.transform_autocomplete_results(result);
      this.fetchedData = {};
      transformed.map(item => this.fetchedData[item.id] = item);
      return transformed.map(item => this.autocomplete_element_template(item)).join('');
    },

    fetchOnceAndFilterLocalResults: async function(url) {
      if (this.fetchedData === undefined) {
        await this.fetchAutocompleteResults(url);
      }
      const query = url.searchParams.get('q');
      const data = Object.values(this.fetchedData);
      const filteredData = query ? this.filterResults(data, query) : data;
      return filteredData.map(item => this.autocomplete_element_template(item)).join('');
    },

    autocompleteID: function() {
      return this.blockID + '-autocomplete';
    },

    getQueryValue: function() {
      const completer = this.inner.querySelector("auto-complete > input");
      return completer.value;
    },

    addAutocompletetoSirTrevorForm: function() {
      const completer = this.inner.querySelector("auto-complete");
      completer.fetchResult = this.autocomplete_fetch.bind(this);
      completer.addEventListener('auto-complete-change', (e) => {
        const data = this.fetchedData[e.relatedTarget.value];
        if (e.relatedTarget.value && data) {
          e.value = e.relatedTarget.value = '';
          this.createItemPanel({ ...data, display: "true" });
        }
      });
    },
  },


  SirTrevor.Block.prototype.availableMixins.push("autocompleteable");
})(jQuery);
