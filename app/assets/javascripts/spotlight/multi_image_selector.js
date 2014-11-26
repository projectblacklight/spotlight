// Module to add multi-image selector to widget panels

(function(){
  $.fn.multiImageSelector = function(thumbnails) {
    var changeLink          = $(" <a href='javascript:;'>Change</a>"),
        thumbsListContainer = $("<div class='thumbs-list' style='display:none'></div>"),
        thumbList           = $("<ul></ul>"),
        panel;

    return init(this);

    function init(el) {
      panel = el;
      if(thumbnails && thumbnails.length > 1) {
        addChangeLink();
        addThumbsList();
      }
    }
    function addChangeLink() {
      $('[data-panel-image-pagination]', panel)
        .html("Image <span data-current-image='true'>" + currentThumbIndex() + "</span> of " + thumbnails.length)
        .show()
        .append(changeLink);
      addChangeLinkBehavior();
    }
    function currentThumb(){
      return $("[data-item-grid-thumbnail]", panel).attr('value');
    }
    function currentThumbIndex(){
      if( (index = thumbnails.indexOf(currentThumb())) > -1 ){
        return index + 1;
      } else {
        return 1;
      }
    }
    function addChangeLinkBehavior() {
      changeLink.on('click', function(){
        thumbsListContainer.slideToggle();
        updateThumbListWidth();
        addScrollBehavior();
        scrollToActiveThumb();
        loadVisibleThumbs();
        swapChangeLinkText($(this));
      });
    }
    function updateThumbListWidth() {
      var width = 0;
      $('li', thumbList).each(function(){
        width += $(this).outerWidth();
      });
      thumbList.width(width + 25);
    }
    function loadVisibleThumbs(){
      var viewportWidth = thumbsListContainer.width();
      var width = 0;
      $('li', thumbList).each(function(){
        var thisThumb  = $(this),
            image      = $('img', thisThumb),
            totalWidth = width += thisThumb.width();
            position   = (thumbList.position().left + totalWidth) - thisThumb.width();

        if(position >= 0 && position < viewportWidth) {
          image.prop('src', image.data('src'));
        }
      });
      updateThumbListWidth();
    }
    function addScrollBehavior(){
      thumbsListContainer.scrollStop(function(){
        updateThumbListWidth();
        loadVisibleThumbs();
      });
    }
    function scrollToActiveThumb(){
      var halfContainerWidth      = (thumbsListContainer.width() / 2),
          activeThumbLeftPosition = ($('.active', thumbList).position() || $('li', thumbList).first().position()).left,
          halfActiveThumbWidth    = ($('.active', thumbList).width() / 2);
      thumbsListContainer.scrollLeft(
        (activeThumbLeftPosition - halfContainerWidth) + halfActiveThumbWidth
      );
    }
    function addThumbsList() {
      addThumbsToList();
      updateActiveThumb();
      $('.panel-heading', panel).append(
        thumbsListContainer.append(
          thumbList
        )
      );
    }
    function updateActiveThumb(){
      $('li', thumbList).each(function(){
        var item = $(this);
        if($('img', item).attr('data-src') == currentThumb()){
          item.addClass('active');
        }
      });
    }
    function swapChangeLinkText(link){
      link.text(
        link.text() == 'Change' ? 'Cancel' : 'Change'
      )
    }
    function addThumbsToList(){
      $.each(thumbnails, function(i){
        var listItem = $('<li><a href="javascript:;"><img data-src="' + thumbnails[i] +'" /></a></li>');
        listItem.on('click', function(){
          var src = $('img', $(this)).attr('src');
          $('li', thumbList).removeClass('active');
          $(this).addClass('active');
          $(".pic.thumbnail img", panel).attr("src", src);
          $("[data-item-grid-thumbnail]", panel).attr('value', src);
          $('[data-panel-image-pagination] [data-current-image]', panel).text(currentThumbIndex());
          scrollToActiveThumb()
        });
        thumbList.append(listItem);
      });
    }
  };

})(jQuery);

// source: http://stackoverflow.com/questions/14035083/jquery-bind-event-on-scroll-stops
jQuery.fn.scrollStop = function(callback) {
  $(this).scroll(function() {
    var self  = this,
    $this = $(self);

    if ($this.data('scrollTimeout')) {
      clearTimeout($this.data('scrollTimeout'));
    }

    $this.data('scrollTimeout', setTimeout(callback, 250, self));
  });
};
