export default class {
  connect() {
    $('[data-autocomplete-tag="true"]').each(function(_i, el) {
      var $el = $(el);
      // By default tags input binds on page ready to [data-role=tagsinput],
      // however, that doesn't work with Turbolinks. So we init manually:
      $el.tagsinput();

      var tags = new Bloodhound({
        datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.name); },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        limit: 100,
        prefetch: {
          url: $el.data('autocomplete-url'),
          ttl: 1,
          filter: function(list) {
            // Let the dom know that the response has been returned
            $el.attr('data-autocomplete-fetched', true);
            return $.map(list, function(tag) { return { name: tag }; });
          }
        }
      });

      tags.initialize();

      $el.tagsinput('input').typeahead({highlight: true, hint: false}, {
        name: 'tags',
        displayKey: 'name',
        source: tags.ttAdapter()
      }).bind('typeahead:selected', $.proxy(function (obj, datum) {
        $el.tagsinput('add', datum.name);
        $el.tagsinput('input').typeahead('val', '');
      })).bind('blur', function() {
        $el.tagsinput('add', $el.tagsinput('input').typeahead('val'));
        $el.tagsinput('input').typeahead('val', '');
      })
    })
  }
}
