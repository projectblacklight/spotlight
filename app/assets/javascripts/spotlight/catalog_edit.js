Spotlight.onLoad(function() {
  if($('#solr_document_exhibit_tag_list').length > 0) {
    // By default tags input binds on page ready to [data-role=tagsinput],
    // however, that doesn't work with Turbolinks. So we init manually:
    $('#solr_document_exhibit_tag_list').tagsinput();

    var tags = new Bloodhound({
      datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.name); },
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      limit: 10,
      prefetch: {
        url: $('#solr_document_exhibit_tag_list').data('autocomplete_url'),
        ttl: 1,
        filter: function(list) {
          return $.map(list, function(tag) { return { name: tag }; });
        }
      }
    });

    tags.initialize();

    $('#solr_document_exhibit_tag_list').tagsinput('input').typeahead({highlight: true, hint: false}, {
      name: 'tags',
      displayKey: 'name',
      source: tags.ttAdapter()
    }).bind('typeahead:selected', $.proxy(function (obj, datum) {
      $('#solr_document_exhibit_tag_list').tagsinput('add', datum.name);
      $('#solr_document_exhibit_tag_list').tagsinput('input').typeahead('val', '');
    })).bind('blur', function() {
      $('#solr_document_exhibit_tag_list').tagsinput('add', $('#solr_document_exhibit_tag_list').tagsinput('input').typeahead('val'));
      $('#solr_document_exhibit_tag_list').tagsinput('input').typeahead('val', '');
    });
  }

      $(".visiblity_toggle").bl_checkbox_submit({
          //css_class is added to elements added, plus used for id base
          css_class: "toggle_visibility",
          //success is called at the end of the ajax success callback
          success: function (public){
            // We store the selector of the label to toggle in a data attribute in the form
            var docTarget = $($(this).data("label-toggle-target"));
            if ( public ) {
              docTarget.removeClass("blacklight-private");
            } else {
              docTarget.addClass("blacklight-private");
            }
          }
      }); 

});
