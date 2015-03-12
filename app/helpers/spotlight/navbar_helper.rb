module Spotlight
  module NavbarHelper
    def should_render_spotlight_search_bar?
      exhibit_masthead? && (current_exhibit.nil? || current_exhibit.searchable?)
    end
  end
end
