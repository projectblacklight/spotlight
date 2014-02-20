module Spotlight
  class Page < ActiveRecord::Base
    MAX_PAGES = 50

    belongs_to :exhibit
    belongs_to :created_by, class_name: "::User"
    belongs_to :last_edited_by, class_name: "::User"
    validates :weight, :inclusion => { :in => Proc.new{ 0..Spotlight::Page::MAX_PAGES } }
    validates :exhibit, presence: true

    default_scope { order("weight ASC") }
    scope :at_top_level, -> { where(parent_page_id: nil) }
    scope :published, -> { where(published: true) }
    scope :recent, -> { order("updated_at DESC").limit(10)}
    
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

    # Subclasses may override this if they have a default
    def title_or_default
      title
    end
  end
end
