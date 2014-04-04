//= require typeahead.bundle.min.js
//= require handlebars-v1.3.0.js

function initBloodhound() {
  results = new Bloodhound({
    datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.title); },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 10,
    remote: {
      url: $('form[data-autocomplete-url]').data('autocomplete-url') + '?q=%QUERY',
      filter: function(response) {
        return $.map(response['docs'], function(doc) {
          return doc;
        })
      }
    }
  });
  results.initialize();
  return results;
}

function addAutocompletetoSirTrevorForm() {
  results = initBloodhound();
  $('[data-twitter-typeahead]').typeahead({ highlight: true, hint: false, autoselect: true }, {
      displayKey: 'title',
      source: results.ttAdapter(),
      templates: {
        suggestion: Handlebars.compile(
          '<div class="document-thumbnail thumbnail"><img src="{{thumbnail}}" /></div>{{title}}<br/><small>&nbsp;&nbsp;{{description}}</small>'
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

function addAutocompletetoFeaturedImage() {
  var typeaheadElement = $('[data-featured-item-typeahead]');
  results = initBloodhound();
  typeaheadElement.typeahead({
      highlight: true,
      hint: false,
      autoselect: true },
      { displayKey: 'title',
        source: results.ttAdapter(),
        templates: {
          suggestion: Handlebars.compile('<div class="document-thumbnail thumbnail"><img src="{{thumbnail}}" /></div>{{title}}<br/><small>&nbsp;&nbsp;{{description}}</small>'
        )
      }
    }).on('click', function() {
      $(this).select();
    }).on('change', function() {
      $($(this).data('id-field')).val("");
    }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
      $($(this).data('id-field')).val(data['id']);
    });
}

Spotlight.onLoad(function(){
  addAutocompletetoFeaturedImage();
});