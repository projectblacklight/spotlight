module Spotlight
  ##
  # Helper for browse views
  module BrowseHelper
    include Blacklight::ConfigurationHelperBehavior
    include Spotlight::RenderingHelper

    ##
    # Get parent results count of a browse category search
    def parent_search_count
      @parent_search_count ||= Spotlight::Search.find(@search.id).count
    end
  end
end
