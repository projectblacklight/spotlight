Spotlight.onLoad(function() {
  // By default tags input binds on page ready to [data-role=tagsinput],
  // however, that doesn't work with Turbolinks. So we init manually:
  $('#solr_document_exhibit_tag_list').tagsinput();
});
