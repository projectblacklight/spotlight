Spotlight.onLoad(function() {
  $(".visiblity_toggle").blCheckboxSubmit({
    //css_class is added to elements added, plus used for id base
    cssClass: "toggle_visibility",
    //success is called at the end of the ajax success callback
    success: function (isPublic){
      // We store the selector of the label to toggle in a data attribute in the form
      var docTarget = $($(this).data("label-toggle-target"));
      if ( isPublic ) {
        docTarget.removeClass("blacklight-private");
      } else {
        docTarget.addClass("blacklight-private");
      }
    }
  });
});
