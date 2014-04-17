module Spotlight
  class Page < ActiveRecord::Base
    MAX_PAGES = 50

    extend FriendlyId
    friendly_id :title, use: [:slugged,:scoped,:finders,:history], scope: :exhibit

    belongs_to :exhibit, touch: true
    belongs_to :created_by, class_name: "::User"
    belongs_to :last_edited_by, class_name: "::User"
    validates :weight, :inclusion => { :in => Proc.new{ 0..Spotlight::Page::MAX_PAGES } }

    default_scope { order("weight ASC") }
    scope :at_top_level, -> { where(parent_page_id: nil) }
    scope :published, -> { where(published: true) }
    scope :recent, -> { order("updated_at DESC").limit(10)}

    # display_sidebar should be set to true by default
    before_create do
      self.display_sidebar = true
    end

    def display_sidebar?
      true
    end

    # explicitly set the partial path so that 
    # we don't have to duplicate view logic.
    def to_partial_path
      "spotlight/pages/page"
    end

    def feature_page?
      is_a? FeaturePage
    end

    def about_page?
      is_a? AboutPage
    end

    def top_level_page?
      try(:parent_page).blank?
    end

    def top_level_page_or_self
      parent_page || self
    end

    def should_generate_new_friendly_id?
      title_changed?
    end

    def should_display_title?
      title.present?
    end

  end
end
