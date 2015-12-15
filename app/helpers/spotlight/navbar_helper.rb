module Spotlight
  ##
  # Helpers used by the navbar
  module NavbarHelper
    ##
    # Check if the spotlight search box should be rendered. It is not displayed
    # if the exhibit is not searchable, we're not in an exhibit, or the top-level
    # exhibit masthead isn't being used (e.g. on a browse category)
    def should_render_spotlight_search_bar?
      current_exhibit && current_exhibit.searchable?
    end
  end
end
