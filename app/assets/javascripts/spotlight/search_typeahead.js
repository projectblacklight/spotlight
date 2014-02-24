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
  $('[data-twitter-typeahead]').typeahead({ highlight: true, hint: false, autoselect: true }, {
      displayKey: 'title',
      source: results.ttAdapter(),
      templates: {
        suggestion: Handlebars.compile(
          '{{title}}<br/><small>&nbsp;&nbsp;{{id}}</small>'
          )
      }
    }).on('click', function() {
      $(this).select();
      $(this).closest('.field').removeClass('has-error');
      $($(this).data('checkbox_field')).prop('disabled', false);
    }).on('change', function() {
      $($(this).data('id_field')).val("");
    }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
      $($(this).data('id_field')).val(data['id']);
      $($(this).data('checkbox_field')).prop('checked', true);
    }).on('blur', function() {
      if($(this).val() != "" && $($(this).data('id_field')).val() == "") {
        $(this).closest('.field').addClass('has-error');
      $($(this).data('checkbox_field')).prop('checked', false);
        $($(this).data('checkbox_field')).prop('disabled', true);
      }
    });
}
results.initialize();
