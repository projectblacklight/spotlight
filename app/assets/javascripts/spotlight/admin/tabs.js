Spotlight.onLoad(function(){
  if ($('[role=tabpanel]').length > 0 && window.location.hash) {
    var tabpanel = $(window.location.hash).closest('[role=tabpanel]');
    $('a[role=tab][href=#'+tabpanel.attr('id')+']').tab('show');  
  }
});