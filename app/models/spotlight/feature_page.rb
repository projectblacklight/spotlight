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

    def display_sidebar?
      child_pages.published.present? || self.display_sidebar
    end
  end
end
