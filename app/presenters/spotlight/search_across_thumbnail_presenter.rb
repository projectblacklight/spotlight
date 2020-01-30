# frozen_string_literal: true

module Spotlight
  # Override the upstream presenter to suppress the thumbnail link if the item belongs to
  # multiple exhibits
  class SearchAcrossThumbnailPresenter < Blacklight::ThumbnailPresenter
    def thumbnail_tag(image_options = {}, url_options = {})
      url_options[:suppress_link] = true if document[Spotlight::SolrDocument.exhibit_slug_field].many?
      super(image_options, url_options)
    end
  end
end
