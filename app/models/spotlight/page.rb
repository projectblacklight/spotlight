module Spotlight
  ##
  # Base page class. See {Spotlight::AboutPage}, {Spotlight::FeaturePage}, {Spotlight::HomePage}
  class Page < ActiveRecord::Base
    MAX_PAGES = 50

    extend FriendlyId
    friendly_id :title, use: [:slugged, :scoped, :finders, :history], scope: :exhibit

    belongs_to :exhibit, touch: true
    belongs_to :created_by, class_name: Spotlight::Engine.config.user_class
    belongs_to :last_edited_by, class_name: Spotlight::Engine.config.user_class
    validates :weight, inclusion: { in: proc { 0..Spotlight::Page::MAX_PAGES } }

    default_scope { order('weight ASC') }
    scope :at_top_level, -> { where(parent_page_id: nil) }
    scope :published, -> { where(published: true) }
    scope :recent, -> { order('updated_at DESC').limit(10) }

    has_one :lock, as: :on, dependent: :destroy
    sir_trevor_content :content
    has_paper_trail

    # display_sidebar should be set to true by default
    before_create do
      self.content ||= [].to_json
      self.display_sidebar = true
    end

    def content_changed!
      @content = nil
    end

    def content=(content)
      if content.is_a? Array
        super content.to_json
      else
        super
      end
      content_changed!
    end

    def content?
      self[:content].present? && content.present?
    end
    alias_method :has_content?, :content?

    def display_sidebar?
      true
    end

    def featured_image
      nil
    end

    # explicitly set the partial path so that
    # we don't have to duplicate view logic.
    def to_partial_path
      'spotlight/pages/page'
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
      super || (title_changed? && persisted?)
    end

    def should_display_title?
      title.present?
    end

    def lock!(user)
      create_lock(by: user).tap(&:current_session!) unless lock.present?
    end
  end
end
