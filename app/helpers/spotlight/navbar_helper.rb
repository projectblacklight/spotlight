module Spotlight
  module NavbarHelper
    def should_render_spotlight_search_bar?
      (!current_exhibit || current_exhibit.searchable?) && !current_search_masthead?
    end
  end
end
