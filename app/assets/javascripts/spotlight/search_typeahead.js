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
    limit: 10,
    remote: {
      url: $('form[data-autocomplete-exhibit-catalog-index-path]').data('autocomplete-exhibit-catalog-index-path').replace("%25QUERY", "%QUERY"),
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

function addAutocompletetoMastheadUpload(){
  if($('[data-masthead-typeahead]').length > 0) {
    $('[data-masthead-typeahead]').spotlightSearchTypeAhead({bloodhound: itemsBloodhound(), template: itemsTemplate()}).on('click', function() {
      $(this).select();
    }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
      var remoteUrlField = $($(this).data('remoteUrlField'));
      var panel = $($(this).data('target-panel'));
      swapInputForPanel($(this), panel, data);
      $($(this).data('id-field')).val(data['global_id']);
      remoteUrlField.val(data['full_images'][0]).trigger('change');
      $(this).attr('type', 'text');
      $('.thumbs-list li', panel).on('click.masthead', function(){
        var index = $('.thumbs-list li').index($(this));
        remoteUrlField.val(data['full_images'][index]).trigger('change');
      });
    });
  }
}

function addAutocompletetoFeaturedImage() {
  if($('[data-featured-item-typeahead]').length > 0) {
    $('[data-featured-item-typeahead]').spotlightSearchTypeAhead({bloodhound: itemsBloodhound(), template: itemsTemplate()}).on('click', function() {
      $(this).select();
    }).on('change', function() {
      $($(this).data('id-field')).val("");
    }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
      $($(this).data('id-field')).val(data['id']);
    });
  }
}

function swapInputForPanel(input, panel, data){
  $(".pic.thumbnail img", panel).attr("src", data['thumbnail']).show();
  $("[data-item-grid-thumbnail]", panel).attr('value', data['thumbnail']);
  $("[data-panel-title]", panel).text(data['title']);

  if(data['private']) {
    panel.addClass("blacklight-private");
  }

  $("[data-panel-id-display]", panel).text(data['id']);
  $(input.data('id_field')).val(data['id']);

  panel.multiImageSelector(data['image_versions']);

  $(input.data('checkbox_field')).prop('checked', true);
  input.attr('type', 'hidden');
  panel.show();
}
function addRemoveAutocompletedPanelBehavior() {
  $("[data-item-grid-panel-remove]").on('click', function(e){
    e.preventDefault();
    var listItem = $(this).closest('li.dd-item');
    var textField = $("[data-target-panel='#" + listItem.attr('id') + "']");
    $("input[type='hidden']", listItem).prop('value', '');
    textField.attr('value', '');
    textField.attr('type', 'text');
    listItem.hide();
  });
}
function replaceName(element, i) {
  element.prop('name', element.prop('name').replace(/\d/, i));
}

Spotlight.onLoad(function(){
  addAutocompletetoFeaturedImage();
  addAutocompletetoMastheadUpload();
});
