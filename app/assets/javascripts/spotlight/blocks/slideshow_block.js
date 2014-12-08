//= require jquery.waitforimages.min.js

(function($){
  var slideshowBlock = function (element, options) {
    this.$element = $(element);
    this.options  = options;
    this.paused   = false;
    this.activeIndex = 0;

    this.init = function() {
      this.$items = this.$element.find('.item');
      this.$indicators = this.$element.find('.slideshow-indicators li');

      this.prepAndStart();
      this.attachEvents();
    }

    this.init();
  }


  slideshowBlock.prototype = {

    // Slide to a given image and adjust indicators
    slide: function(item) {
      if (this.elementExistsInDom()) {
        this.activeIndex = this.$items.index(item);

        this.$items.hide();
        $(item).fadeIn();

        this.$indicators.removeClass('active');
        $(this.$indicators[this.activeIndex]).addClass('active');

        if (this.options.autoPlay && !this.paused) this.play();

        return this;

      } else {
        this.destroy();
      }
    },

    // Play slideshow using preset interval
    play: function() {
      this.paused = false;

      if (this.interval) clearInterval(this.interval);
      this.interval = setInterval($.proxy(this.next, this), this.options.interval);
    },

    // Pause slideshow
    pause: function() {
      this.paused = true;
      this.interval = clearInterval(this.interval);

      return this;
    },

    // Next function for attaching events in play
    next: function() {
      return this.to('next');
    },

    // Navigate to
    to: function(pos) {
      if (pos === 'next') pos = this.activeIndex + 1;
      if (pos === 'prev') pos = this.activeIndex - 1;

      return this.slide(this.$items[this.getValidIndex(pos)]);
    },

    // Validate a given index
    getValidIndex: function(index) {
      if (typeof index === 'undefined' || index > (this.$items.length - 1)) index = 0;
      if (index < 0) index = this.$items.length - 1;

      return index;
    },

    // Resize/re-position elements to a fixed and start slideshow
    prepAndStart: function() {
      var maxHeight = 1,
          _this = this;

      // wait for all images to load, find the biggest image size and balance others
      this.$element.waitForImages(function() {
        $.each(_this.$items.find('a > img'), function(index, img) {
          maxHeight = Math.max(maxHeight, $(img).outerHeight());
        });

        maxHeight = Math.min(maxHeight, _this.options.size);

        $.each(_this.$items, function(index, item) {
          var img = $(item).find('a > img');

          // resize the image (if larger than config size)
          $(img).height(Math.min(_this.options.size, $(img).height()));

          // vertically align smaller images to bottom
          $(img).css('margin-top', maxHeight - $(img).outerHeight());

          $(item).height(maxHeight + $(item).find('.caption').outerHeight());
        });

        _this.to(_this.activeIndex);
      });
    },

    // Attach event handlers
    attachEvents: function() {
      var $img = this.$element.find('.item a > img'),
          $caption = this.$element.find('.caption'),
          _this = this;

      // pause slideshow on image mouseenter event
      $img.on('mouseenter', function() {  _this.pause(); });

      // play slideshow on image mouseleave event
      $img.on('mouseleave', function() {
        if (_this.options.autoPlay) _this.play();
      });

      // show full caption text (primary & secondary) on mouseenter
      $caption.on('mouseenter', function() {
        var $caption = $(this),
            $primary = $caption.find('.primary'),
            $secondary = $caption.find('.secondary');

        $primary.addClass('caption-hover');
        $secondary.addClass('caption-hover');

        if ($secondary.length > 0) {
          $primary.css('bottom', $secondary.height());
        }
      });

      // revert back to one-line caption text (primary & secondary) on mouseleave
      $caption.on('mouseleave', function() {
        var $caption = $(this),
            $primary = $caption.find('.primary'),
            $secondary = $caption.find('.secondary');

        $primary.removeClass('caption-hover').css('bottom', 0);
        $secondary.removeClass('caption-hover');
      });

      this.$element.on('click', '[data-slide], [data-slide-to]', function(e) {
        pos = parseInt($(this).attr('data-slide-to'), 10) || $(this).attr('data-slide');

        _this.pause();
        _this.to(pos);
        e.preventDefault();
      });
    },

    // Destroy obsolete slideshow objects
    destroy: function() {
      this.pause();
      this.$element.removeData('slideshowBlock').unbind('slideshowBlock').remove();
    },

    // Check if element exists in DOM
    elementExistsInDom: function() {
      return $(document).find(this.$element).length !== 0 ? true : false;
    }
  }


  // Plugin default options
  slideshowBlock.DEFAULTS = {
    size: 350,
    autoPlay: true,
    interval: 5000 // in milliseconds
  }


  // Plugin definition
  $.fn.slideshowBlock = function(options) {
    return this.each(function() {
      var $this = $(this);
      var options = $.extend({}, slideshowBlock.DEFAULTS, $this.data(), typeof options == 'object' && options);

      $this.data('slideshowBlock', new slideshowBlock(this, options));
    })
  }

})(jQuery);


Spotlight.onLoad(function() {
  $('.slideshow-block').slideshowBlock();
});



