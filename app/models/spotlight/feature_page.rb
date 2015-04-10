module Spotlight
  ##
  # Feature pages
  class FeaturePage < Spotlight::Page
    extend FriendlyId
    friendly_id :title, use: [:slugged, :scoped, :finders, :history], scope: :exhibit

    has_many :child_pages, class_name: 'Spotlight::FeaturePage', inverse_of: :parent_page, foreign_key: 'parent_page_id'
    belongs_to :parent_page, class_name: 'Spotlight::FeaturePage'

    accepts_nested_attributes_for :child_pages

    belongs_to :thumbnail, class_name: 'Spotlight::FeaturedImage', dependent: :destroy
    accepts_nested_attributes_for :thumbnail, update_only: true

    before_validation unless: :top_level_page? do
      self.exhibit = top_level_page_or_self.exhibit
    end

    def display_sidebar?
      child_pages.published.present? || display_sidebar
    end

    def thumbnail_image_url
      thumbnail.image.thumb.url if thumbnail && thumbnail.image
    end
  end
end
