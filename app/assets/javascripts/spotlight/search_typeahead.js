//= require typeahead.bundle.min.js
//= require handlebars-v1.3.0.js

(function($){
  $.fn.spotlightSearchTypeAhead = function( options ) {
    $.each(this, function(){
      addAutocompleteBehavior($(this));
    });

    function addAutocompleteBehavior( typeAheadInput, settings ) {
      var settings = $.extend({
        highlight: (typeAheadInput.data('autocomplete-highlight') || true),
        hint: (typeAheadInput.data('autocomplete-hint') || false),
        autoselect: (typeAheadInput.data('autocomplete-autoselect') || true)
      }, options);
      
      var results;
      if (settings.bloodhound) {
        results = settings.bloodhound();
      } else {
        results = initBloodhound();
      }

      typeAheadInput.typeahead(settings, {
        displayKey: 'title',
        source: results.ttAdapter(),
        templates: {
          suggestion: Handlebars.compile('<div class="autocomplete-item{{#if private}} blacklight-private{{/if}}">{{#if thumbnail}}<div class="document-thumbnail thumbnail"><img src="{{thumbnail}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>')
        }
      })
    }
    return this;
  }
})( jQuery );

function initBloodhound() {
  var results = new Bloodhound({
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

function addAutocompletetoSirTrevorForm(options) {
  $('[data-twitter-typeahead]').spotlightSearchTypeAhead(options).on('click', function() {
    $(this).select();
    $(this).closest('.field').removeClass('has-error');
    $($(this).data('checkbox_field')).prop('disabled', false);
  }).on('change', function() {
    $($(this).data('id_field')).val("");
  }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
    swapInputForPanel($(this), $($(this).data('target-panel')) , data);
    if(nextTextField = $('input[type="text"]', $(this).closest('.field').next('.field'))) {
      nextTextField.focus();
    }
  }).on('blur', function() {
    if($(this).val() != "" && $($(this).data('id_field')).val() == "") {
      $(this).closest('.field').addClass('has-error');
      $($(this).data('checkbox_field')).prop('checked', false);
      $($(this).data('checkbox_field')).prop('disabled', true);
    }
  });
}

function addAutocompletetoMastheadUpload(){
  $('[data-masthead-typeahead]').spotlightSearchTypeAhead().on('click', function() {
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

function addAutocompletetoFeaturedImage() {
  $('[data-featured-item-typeahead]').spotlightSearchTypeAhead().on('click', function() {
    $(this).select();
  }).on('change', function() {
    $($(this).data('id-field')).val("");
  }).on('typeahead:selected typeahead:autocompleted', function(e, data) {
    $($(this).data('id-field')).val(data['id']);
  });
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

  panel.multiImageSelector(data['thumbnails']);

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
