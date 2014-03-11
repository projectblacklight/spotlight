(function($){
  var Slideshow = function (element, options) {
    this.$element = $(element)
    this.options  = options
    this.$pauseButton = this.$element.find('[data-state=pause]')
    this.$playButton = this.$element.find('[data-state=play]')
    this.init = function() {
      this.initialCaption();
      //caption when a slide happens
      this.$element.on('slide.bs.carousel', $.proxy(this.changeCaption, this));
      this.$pauseButton.on('click', $.proxy(this.pause, this));
      this.$playButton.on('click', $.proxy(this.play, this));
      this.$element.find('[data-velocity]').on('click', $.proxy(this.adjustSpeed, this));
      this.$playButton.hide()
      this.$element.carousel(this.options);
    }
    this.init();
  }


  Slideshow.prototype = {
    changeCaption: function (evt) {
      this.updateIndex($(evt.relatedTarget).index() + 1);
      this.caption($(evt.relatedTarget).find('.carousel-caption').html());
    },

    // Set initial caption
    initialCaption: function () {
      this.caption(this.$element.find('.item.active .carousel-caption').html());
      this.updateIndex(1);
    },
    
    caption: function(value) {
      this.$element.find('#slideshow-caption').html(value);
    },

    updateIndex: function(value) {
      this.$element.find('#current-slideshow-index').html(value);
    },

    pause: function(evt) {
      evt.preventDefault();
      this.$pauseButton.hide();
      this.$playButton.show();
      this.$element.carousel('pause');
    },

    play: function(evt) {
      evt.preventDefault();
      this.$pauseButton.show();
      this.$playButton.hide();
      this.$element.carousel('cycle');
    },

    adjustSpeed: function(evt) {
      var speed = parseInt($(evt.target).val());
      this.$element.data('bs.carousel').options.interval = speed;
      this.$element.carousel('pause').carousel('cycle');
    },

    openSlide: function(slide) {
      this.$element.carousel(slide);
    }
  }

  Slideshow.DEFAULTS = {
        interval: 3000,
        pause: false,
        wrap: true
  }

  $.fn.slideshow = function( option ) {
    return this.each(function() {
      var $this = $(this)
      var data  = $this.data('slideshow')
      var options = $.extend({}, Slideshow.DEFAULTS, $this.data(), typeof option == 'object' && option)
      if (!data) $this.data('slideshow', (data = new Slideshow(this, options)))
    })
  }
})( jQuery ); 

Spotlight.onLoad(function() {
  $('#slideshow').slideshow();
});
