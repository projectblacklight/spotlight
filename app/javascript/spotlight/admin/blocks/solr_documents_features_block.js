//= require spotlight/admin/blocks/solr_documents_base_block

SirTrevor.Blocks.SolrDocumentsFeatures = (function(){

  return SirTrevor.Blocks.SolrDocumentsBase.extend({
    plustextable: false,
    type: "solr_documents_features",

    icon_name: "item_features",

    afterPreviewLoad: function(options) {
      $(this.inner).find('.carousel').carousel();

      // the bootstrap carousel only initializes data-slide widgets on page load, so we need
      // to initialize them ourselves..
      var clickHandler = function (e) {
        var href
        var $this   = $(this)
        var $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) // strip for ie7
        if (!$target.hasClass('carousel')) return
        var options = $.extend({}, $target.data(), $this.data())
        var slideIndex = $this.attr('data-slide-to')
        if (slideIndex) options.interval = false

        $.fn.carousel.call($target, options)

        if (slideIndex) {
          $target.data('bs.carousel').to(slideIndex)
        }

        e.preventDefault()
      }

      $(this.inner).find('.carousel')
        .on('click.bs.carousel.data-api', '[data-slide]', clickHandler)
        .on('click.bs.carousel.data-api', '[data-slide-to]', clickHandler)
    }

  });

})();
