# frozen_string_literal: true

module Spotlight
  # Override the upstream presenter in order to change the thumbnail presenter
  class SearchAcrossIndexPresenter < Blacklight::IndexPresenter
    self.thumbnail_presenter = SearchAcrossThumbnailPresenter
  end
end
