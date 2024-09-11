import SirTrevor from 'sir-trevor'

SirTrevor.Locales.en.blocks = $.extend(SirTrevor.Locales.en.blocks, {
  autocompleteable: {
    placeholder: "Enter a title..."
  },

  browse: {
    title: "Browse Categories",
    description: "This widget highlights browse categories. Each highlighted category links to the corresponding browse category results page.",
    item_counts: "Include item counts?"
  },

  browse_group_categories: {
    autocomplete: "Enter a browse group title...",
    title: "Browse Group Categories",
    description: "This widget displays all browse categories associated with a selected browse group as a horizontally-scrolling row. Each selected browse group is displayed as a separate row. Each displayed category in a group links to the corresponding browse category results page.",
    item_counts: "Include category item counts?"
  },

  link_to_search: {
    title: "Saved Searches",
    description: "This widget highlights saved searches. Each highlighted saved search links to the search results page generated by the saved search parameters. Any saved search listed on the Curation > Browse categories page, whether published or not, can be highlighted as a saved search.",
    item_counts: "Include item counts?"
  },

  iframe: {
    title:  "IFrame",
    description: "This widget embeds iframe-based embed code into pages",
    placeholder: "Enter embed code here. It should begin with e.g. '<iframe'"
  },

  oembed: {
    title: "Embed + Text",
    description: "This widget embeds an oEmbed-supported web resource and a text block to the left or right of it. Examples of oEmbed-supported resources include those from YouTube, Twitter, Flickr, and SlideShare.",
    url: "URL",
  },

  uploaded_items: {
    title: "Uploaded Item Row",
    description: "This widget displays uploaded items in a horizontal row. Optionally, you can add a heading and/or text to be displayed adjacent to the items. The item caption and link URL fields are also optional.",
    caption: 'Caption',
    link: 'Link URL'
  },

  featured_pages: {
    title:  "Pages",
    description: "This widget highlights pages from this exhibit. Each highlighted item links to the corresponding page."
  },

  resources: {
    panel: {
      drag: "Drag",
      display: "Display?",
      remove: "Remove"
    },
    alt_text: {
      decorative: "Decorative",
      alternative_text: "Alternative text",
      placeholder: "Enter alt text for this item..."
    }
  },

  rule: {
    title: "Horizontal Rule"
  },

  search_results: {
    title: "Search Results",
    description: "This widget displays a set of search results on a page. Specify a search result set by selecting an existing browse category. You can also select the view types that are available to the user when viewing the result set."
  },

  solr_documents: {
    title: "Item Row",
    description: "This widget displays exhibit items in a horizontal row. Optionally, you can add a heading and/or text to be displayed adjacent to the items.",
    caption: {
      placeholder: "Select...",
      primary: "Primary caption",
      secondary: "Secondary caption"
    },
    zpr: {
      title: 'Offer "View larger" option'
    }
  },

  solr_documents_carousel: {
    title: "Item Carousel",
    description: "This widget displays exhibit items in a carousel. You can configure the item captions, how the images are cycled, and the size of the carousel.",
    interval: {
      title: "Automatically cycle images",
      placeholder: "Select..."
    },
    height: {
      title: "Maximum carousel height"
    }
  },

  solr_documents_embed: {
    title: "Item Embed",
    description: "This widget embeds an exhibit item in a viewer on a page. Optionally, you can add a heading to be displayed above the viewer and/or text to be displayed adjacent to the viewer.",
  },

  solr_documents_features: {
    title: "Item Slideshow",
    description: "This widget displays exhibit items in a static slideshow. The user will move between items in the slideshow using the field you select as the primary caption."
  },

  solr_documents_grid: {
    title: "Item Grid",
    description: "This widget displays exhibit items in a multi-row grid. Optionally, you can add a heading and/or text to be displayed adjacent to the items."
  },

  textable: {
    heading: "Heading",
    text: "Text",
    align: {
      title: "Display text on:",
      left: "Left",
      right: "Right"
    }
  },

  group: {
    undefined: "Standard widgets",
    items: "Exhibit item widgets"
  },

  alt_text_guidelines: {
    intro: 'For each item, please enter alternative text or appropriately check the decorative box. ',
    link_label: 'Guidelines for writing alt text.',
    link_url: 'https://www.w3.org/WAI/tutorials/images/' 
  }
});
