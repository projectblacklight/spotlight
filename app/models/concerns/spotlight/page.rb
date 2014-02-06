module Spotlight
  module Page
    MAX_PAGES = 50

    extend ActiveSupport::Concern
    included do
      belongs_to :exhibit
      validates :weight, :inclusion => { :in => Proc.new{ 0..Spotlight::Page::MAX_PAGES } }
      validates :exhibit, presence: true

      default_scope { order("weight ASC") }
      scope :at_top_level, -> { where(parent_page_id: nil) }
      scope :published, -> { where(published: true) }
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
  end
end
