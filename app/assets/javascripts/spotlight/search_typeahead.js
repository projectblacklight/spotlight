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
      addImageSelector($(this), panel, data.iiif_manifest);
      $($(this).data('id-field')).val(data['global_id']);
      $(this).attr('type', 'text');
    });
  }
}

function addImageSelector(input, panel, manifestUrl) {
  if (!manifestUrl) {
    showNonIiifAlert(input);
    return;
  }
  var cropper = input.data('iiifCropper');
  $.ajax(manifestUrl).success(
    function(manifest) {
      var thumbs = [];
      manifest.sequences.forEach(function(sequence) {
        sequence.canvases.forEach(function(canvas) {
          canvas.images.forEach(function(image) {
            var iiifService = image.resource.service['@id'];
            thumbs.push(
              {
                'thumb': iiifService + '/full/!100,100/0/default.jpg',
                'tilesource': iiifService + '/info.json'
              }
            );
          });
        });
      });

      hideNonIiifAlert(input);

      if(thumbs.length == 1) {
        cropper.setTileSource(thumbs[0].tilesource);
      } else {
        panel.show();
        panel.multiImageSelector(thumbs, function(selectorImage) {
          cropper.setTileSource(selectorImage.tilesource);
        });
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
