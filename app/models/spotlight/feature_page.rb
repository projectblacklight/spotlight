# frozen_string_literal: true

module Spotlight
  ##
  # Feature pages
  class FeaturePage < Spotlight::Page
    extend FriendlyId
    friendly_id :title, use: %i[slugged scoped finders history], scope: %i[exhibit locale] do |config|
      config.reserved_words&.concat(%w[update_all])
    end

    has_many :child_pages_for_all_locales, class_name: 'Spotlight::FeaturePage', inverse_of: :parent_page, foreign_key: 'parent_page_id'
    belongs_to :parent_page, class_name: 'Spotlight::FeaturePage', optional: true

    accepts_nested_attributes_for :child_pages_for_all_locales

    before_validation unless: :top_level_page? do
      self.exhibit = top_level_page_or_self.exhibit
    end

    def child_pages
      child_pages_for_all_locales.where(locale:)
    end

    def display_sidebar?
      child_pages.published.present? || display_sidebar
    end
  end
end
