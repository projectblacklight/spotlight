Spotlight.onLoad(function() {
  $("#preview").attr('src', $("#search_featured_image").val());
  $("#search_featured_image").on("change", function() {
    $("#preview").attr('src', $(this).val());
  });
});
