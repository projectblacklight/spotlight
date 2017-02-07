//= require typeahead.bundle.min.js
//= require handlebars-v1.3.0.js

(function($){
  $.fn.spotlightSearchTypeAhead = function( options ) {
    $.each(this, function(){
      addAutocompleteBehavior($(this));
    });

    function addAutocompleteBehavior( typeAheadInput, settings ) {
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
          suggestion: Handlebars.compile(settings.template)
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

function itemsTemplate() {
  return '<div class="autocomplete-item{{#if private}} blacklight-private{{/if}}">{{#if thumbnail}}<div class="document-thumbnail thumbnail"><img src="{{thumbnail}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>';
}

function addAutocompletetoFeaturedImage(){
  if($('[data-featured-image-typeahead]').length > 0) {
    $('[data-featured-image-typeahead]').spotlightSearchTypeAhead({bloodhound: itemsBloodhound(), template: itemsTemplate()}).on('click', function() {
      $(this).select();
    }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
      var panel = $($(this).data('target-panel'));
      addImageSelector($(this), panel, data.iiif_manifest, true);
      $($(this).data('id-field')).val(data['global_id']);
      $(this).attr('type', 'text');
    });
  }
}

function addImageSelector(input, panel, manifestUrl, initialize) {
  if (!manifestUrl) {
    showNonIiifAlert(input);
    return;
  }
  var cropper = input.data('iiifCropper');
  $.ajax(manifestUrl).success(
    function(manifest) {
      var Iiif = require('spotlight/iiif');
      var iiifManifest = new Iiif(manifestUrl, manifest);

      var thumbs = iiifManifest.imagesArray();

      hideNonIiifAlert(input);

      if (initialize) {
        cropper.setIiifFields(thumbs[0]);
      }

      if(thumbs.length > 1) {
        panel.show();
        panel.multiImageSelector(thumbs, function(selectorImage) {
          cropper.setIiifFields(selectorImage);
        }, cropper.iiifImageField.val());
      }
    }
  );
}

function showNonIiifAlert(input){
  input.parent().prev('[data-behavior="non-iiif-alert"]').show();
}

function hideNonIiifAlert(input){
  input.parent().prev('[data-behavior="non-iiif-alert"]').hide();
}

Spotlight.onLoad(function(){
  addAutocompletetoFeaturedImage();
});
