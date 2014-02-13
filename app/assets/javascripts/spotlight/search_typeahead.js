//= require typeahead.bundle.min.js
//= require handlebars-v1.3.0.js

var results = new Bloodhound({
  datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.title); },
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  limit: 10,
  remote: {
    url: '/catalog.json?q=%QUERY',
    filter: function(response) {
      return $.map(response['response']['docs'], function(doc) {
        return { id: doc['id'], title: doc['full_title_tesim'][0] }
      })
    }
  }
});

function addAutocompletetoSirTrevorForm() {
  $('input[name="item-id"]').typeahead(null, {
      displayKey: 'id',
      source: results.ttAdapter(),
      templates: {
        suggestion: Handlebars.compile(
          '{{title}}<br/><small>&nbsp;&nbsp;{{id}}</small>'
          )
      }
    });
}
results.initialize();

Spotlight.onLoad(function() {
  SirTrevor.EventBus.on("block:create:new", addAutocompletetoSirTrevorForm);
});