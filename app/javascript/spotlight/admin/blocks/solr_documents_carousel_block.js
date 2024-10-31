//= require spotlight/admin/blocks/solr_documents_base_block

SirTrevor.Blocks.SolrDocumentsCarousel = (function(){

  return SirTrevor.Blocks.SolrDocumentsBase.extend({
    plustextable: false,
    type: "solr_documents_carousel",

    icon_name: "item_carousel",

    auto_play_images_key: "auto-play-images",
    auto_play_images_interval_key: "auto-play-images-interval",
    max_height_key: "max-height",

    carouselCycleTimesInSeconds: {
      values: [ 3, 5, 8, 12, 20 ],
      selected: 5
    },

    carouselMaxHeights: {
      values: { 'Small': 'small', 'Medium': 'medium', 'Large': 'large' },
      selected: 'Medium'
    },

    item_options: function() {
      return `${this.caption_options()}
        <div class="field-select auto-cycle-images" data-behavior="auto-cycle-images">
          <input name="${this.auto_play_images_key}" type="hidden" value="false" />
          <input name="${this.auto_play_images_key}" id="${this.formId(this.auto_play_images_key)}" data-key="${this.auto_play_images_key}" type="checkbox" value="true" checked/>
          <label for="${this.formId(this.auto_play_images_key)}">${i18n.t("blocks:solr_documents_carousel:interval:title")}</label>
          <select name="${this.auto_play_images_interval_key}" id="${this.formId(this.auto_play_images_interval_key)}" data=key="${this.auto_play_images_interval_key}">
            <option value="">${i18n.t("blocks:solr_documents_carousel:interval:placeholder")}</option>
            ${this.addCarouselCycleOptions(this.carouselCycleTimesInSeconds)}
          </select>
        </div>
        <div class="field-select max-heights" data-behavior="max-heights">
          <label for="${this.formId(this.max_height_key)}">${i18n.t("blocks:solr_documents_carousel:height:title")}</label><br/>
          ${this.addCarouselMaxHeightOptions(this.carouselMaxHeights)}
        </div>`
    },

    addCarouselCycleOptions: function(options) {
      var html = '';

      $.each(options.values, function(index, interval) {
        var selected = (interval === options.selected) ? 'selected' : '',
            intervalInMilliSeconds = parseInt(interval, 10) * 1000;

        html += '<option value="' + intervalInMilliSeconds + '" ' + selected + '>' + interval + ' seconds</option>';
      });

      return html;
    },

    addCarouselMaxHeightOptions: function(options) {
      var html = '',
          _this = this;

      $.each(options.values, function(size, px) {
        var checked = (size === options.selected) ? 'checked' : '',
            id = _this.formId(_this.max_height_key)

        html += '<input data-key="' + _this.max_height_key + '" type="radio" name="' + id + '" value="' + px + '" id="' + id + '" ' + checked + '>';
        html += '<label class="carousel-size" for="' + id + '">' + size + '</label>';
      });

      return html;
    },

    afterPreviewLoad: function(options) {
      $(this.inner).find('.carousel').carousel();

      // the bootstrap carousel only initializes data-bs-slide widgets on page load, so we need
      // to initialize them ourselves..
      var clickHandler = function (e) {
        var href
        var $this   = $(this)
        var $target = $($this.attr('data-target') || $this.attr('data-bs-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) // strip for ie7
        if (!$target.hasClass('carousel')) return
        var options = $.extend({}, $target.data(), $this.data())
        var slideIndex = $this.attr('data-slide-to') || $this.attr('data-bs-slide-to')
        if (slideIndex) options.interval = false

        $.fn.carousel.call($target, options)

        if (slideIndex) {
          $target.data('bs.carousel').to(slideIndex)
        }

        e.preventDefault()
      }

      $(this.inner).find('.carousel')
        .on('click.bs.carousel.data-api', '[data-slide], [data-bs-slide]', clickHandler)
        .on('click.bs.carousel.data-api', '[data-slide-to], [data-bs-slide-to]', clickHandler)
    }

  });

})();
