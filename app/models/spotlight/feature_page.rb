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
    accepts_nested_attributes_for :thumbnail, update_only: true, reject_if: :all_blank

    before_validation unless: :top_level_page? do
      self.exhibit = top_level_page_or_self.exhibit
    end

    def display_sidebar?
      child_pages.published.present? || display_sidebar
    end

    def thumbnail_image_url
      return unless thumbnail && thumbnail.iiif_url
      thumbnail.iiif_url
    end
  end
end
