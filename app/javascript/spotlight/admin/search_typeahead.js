import { addImageSelector } from 'spotlight/admin/add_image_selector'

(function($){
  $.fn.spotlightSearchTypeAhead = function( options ) {
    $.each(this, function(){
      addAutocompleteBehavior($(this));
    });

    function addAutocompleteBehavior( typeAheadInput, _ ) {
      var settings = $.extend({
        displayKey: 'title',
        minLength: 0,
        highlight: (typeAheadInput.data('autocomplete-highlight') || true),
        hint: (typeAheadInput.data('autocomplete-hint') || false),
        autoselect: (typeAheadInput.data('autocomplete-autoselect') || true)
      }, options);
      typeAheadInput.typeahead(settings, {
        displayKey: settings.displayKey,
        source: settings.bloodhound.ttAdapter(),
        templates: {
          suggestion: settings.template
        }
      })
    }
    return this;
  }
})( jQuery );

function itemsBloodhound() {
  var results = new Bloodhound({
    datumTokenizer: function(d) {
      return Bloodhound.tokenizers.whitespace(d.title);
    },
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 100,
    remote: {
      url: $('form[data-autocomplete-exhibit-catalog-path]').data('autocomplete-exhibit-catalog-path').replace("%25QUERY", "%QUERY"),
      filter: function(response) {
        return $.map(response['docs'], function(doc) {
          return doc;
        })
      }
    }
  });
  results.initialize();
  return results;
};

function templateFunc(obj) {
  const thumbnail = obj.thumbnail ? `<div class="document-thumbnail"><img class="img-thumbnail" src="${obj.thumbnail}" /></div>` : ''
  return $(`<div class="autocomplete-item${obj.private ? ' blacklight-private' : ''}">${thumbnail}
  <span class="autocomplete-title">${obj.title}</span><br/><small>&nbsp;&nbsp;${obj.description}</small></div>`)
}

export function addAutocompletetoFeaturedImage(){
  if($('[data-featured-image-typeahead]').length > 0) {
    $('[data-featured-image-typeahead]').spotlightSearchTypeAhead({bloodhound: itemsBloodhound(), template: templateFunc}).on('click', function() {
      $(this).select();
    }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
      var panel = $($(this).data('target-panel'));
      addImageSelector($(this), panel, data.iiif_manifest, true);
      $($(this).data('id-field')).val(data['global_id']);
      $(this).attr('type', 'text');
    });
  }
}
