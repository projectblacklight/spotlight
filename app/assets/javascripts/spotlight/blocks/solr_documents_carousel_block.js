//= require spotlight/blocks/solr_documents_block

SirTrevor.Blocks.SolrDocumentsCarousel = (function(){

  return SirTrevor.Blocks.SolrDocuments.extend({
    textable: false,
    type: "solr_documents_carousel",
    title: function() { return "Item Carousel"; },

    icon_name: "item_carousel",
    blockGroup: 'Exhibit item widgets',
    description: "This widget displays thumbnail images of repository items in a carousel. You can configure the captions that appear below each carousel image and how the images are cycled.",
    
    auto_play_images_key: "auto-play-images",
    auto_play_images_interval_key: "auto-play-images-interval",
    max_height_key: "max-height",

    item_options: function() { return "" },
    
    carouselCycleTimesInSeconds: {
      values: [ 3, 5, 8, 12, 20 ],
      selected: 5
    },

    carouselMaxHeights: {
      values: { 'Small': 'small', 'Medium': 'medium', 'Large': 'large' },
      selected: 'Medium'
    },

    item_options: function() {
      return [this.caption_options(),
        '<div class="field-select auto-cycle-images" data-behavior="auto-cycle-images">',
          '<input name="<%= auto_play_images_key %>" type="hidden" value="false" />',
          '<input name="<%= auto_play_images_key %>" id="<%= formId(auto_play_images_key) %>" data-key="<%= auto_play_images_key %>" type="checkbox" value="true" checked/>',
          '<label for="<%= formId(auto_play_images_key) %>">Automatically cycle images</label>',
          '<select name="<%= auto_play_images_interval_key %>" id="<%= formId(auto_play_images_interval_key) %>" data=key="<%= auto_play_images_interval_key %>">',
            '<option value="">Select...</option>',
            '<%= addCarouselCycleOptions(carouselCycleTimesInSeconds) %>',
          '</select>',
        '</div>',
        '<div class="field-select max-heights" data-behavior="max-heights">',
          '<label for="<%= formId(max_height_key) %>">Maximum carousel height</label><br/>',
          '<%= addCarouselMaxHeightOptions(carouselMaxHeights) %>',
        '</div>',
      ].join("\n");
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
    }

  });

})();