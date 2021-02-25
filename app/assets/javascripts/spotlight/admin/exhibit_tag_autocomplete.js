Spotlight.onLoad(function() {
  if($('[data-autocomplete-tag="true"]').length > 0) {
    // By default tags input binds on page ready to [data-role=tagsinput],
    // however, that doesn't work with Turbolinks. So we init manually:
    $('[data-autocomplete-tag="true"]').tagsinput();

    var tags = new Bloodhound({
      datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.name); },
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      limit: 100,
      prefetch: {
        url: $('[data-autocomplete-tag="true"]').data('autocomplete-url'),
        ttl: 1,
        filter: function(list) {
          return $.map(list, function(tag) { return { name: tag }; });
        }
      }
    });

    tags.initialize();

    $('[data-autocomplete-tag="true"]').tagsinput('input').typeahead({highlight: true, hint: false}, {
      name: 'tags',
      displayKey: 'name',
      source: tags.ttAdapter()
    }).bind('typeahead:selected', $.proxy(function (obj, datum) {
      $('[data-autocomplete-tag="true"]').tagsinput('add', datum.name);
      $('[data-autocomplete-tag="true"]').tagsinput('input').typeahead('val', '');
    })).bind('blur', function() {
      $('[data-autocomplete-tag="true"]').tagsinput('add', $('[data-autocomplete-tag="true"]').tagsinput('input').typeahead('val'));
      $('[data-autocomplete-tag="true"]').tagsinput('input').typeahead('val', '');
    });
  }
});
