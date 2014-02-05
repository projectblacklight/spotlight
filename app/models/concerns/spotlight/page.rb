module Spotlight::Page
  MAX_PAGES = 50

  extend ActiveSupport::Concern
  included do
    belongs_to :exhibit
    validates :weight, :inclusion => { :in => Proc.new{ 0..Spotlight::Page::MAX_PAGES } }
    validates :exhibit, presence: true

    default_scope { order("weight ASC") }
  end
  # explicitly set the partial path so that 
  # we don't have to duplicate view logic.
  def to_partial_path
    "spotlight/pages/page"
  end
  def feature_page?
    self.is_a?(Spotlight::FeaturePage)
  end
  def top_level_page?
    self.parent_page.blank?
  end
end
