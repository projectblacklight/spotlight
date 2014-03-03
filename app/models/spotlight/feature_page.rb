module Spotlight
  class FeaturePage < Spotlight::Page
    extend FriendlyId
    friendly_id :title, use: [:slugged,:scoped,:finders,:history], scope: :exhibit

    has_many   :child_pages, class_name: "Spotlight::FeaturePage", inverse_of: :parent_page, foreign_key: "parent_page_id"
    belongs_to :parent_page, class_name: "Spotlight::FeaturePage"

    accepts_nested_attributes_for :child_pages

    before_validation unless: :top_level_page? do
      self.exhibit = top_level_page_or_self.exhibit
    end

    after_save do
      display_sidebar_for_page_with_published_children
      display_parent_page_sidebar_when_published
    end
    private
    # Parent pages with published children need
    # to have their show_sidebar forced to true
    def display_sidebar_for_page_with_published_children
      if child_pages.published.present? and !display_sidebar
        self.display_sidebar = true
        self.save
      end
    end
    # Force a parent page's display_sidebar
    # to true for published child pages.
    def display_parent_page_sidebar_when_published
      if parent_page and parent_page.published and !parent_page.display_sidebar
        if published
          parent_page.display_sidebar = true
          parent_page.save
        end
      end
    end
  end
end
