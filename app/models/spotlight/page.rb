module Spotlight
  ##
  # Base page class. See {Spotlight::AboutPage}, {Spotlight::FeaturePage}, {Spotlight::HomePage}
  # rubocop:disable Metrics/ClassLength
  class Page < ActiveRecord::Base
    MAX_PAGES = 50

    extend FriendlyId
    friendly_id :title, use: [:slugged, :scoped, :finders, :history], scope: [:exhibit, :locale]

    belongs_to :exhibit, touch: true
    belongs_to :created_by, class_name: Spotlight::Engine.config.user_class, optional: true
    belongs_to :last_edited_by, class_name: Spotlight::Engine.config.user_class, optional: true
    belongs_to :thumbnail, class_name: 'Spotlight::FeaturedImage', dependent: :destroy, optional: true
    belongs_to :default_locale_page, class_name: 'Spotlight::Page', optional: true, inverse_of: :translated_pages
    has_many :translated_pages,
             class_name: 'Spotlight::Page',
             foreign_key: :default_locale_page_id,
             dependent: :destroy,
             inverse_of: :default_locale_page

    validates :weight, inclusion: { in: proc { 0..Spotlight::Page::MAX_PAGES } }

    default_scope { order('weight ASC') }
    scope :at_top_level, -> { where(parent_page_id: nil) }
    scope :published, -> { where(published: true) }
    scope :recent, -> { order('updated_at DESC').limit(10) }
    scope :for_locale, ->(locale = I18n.locale) { unscope(where: :locale).where(locale: locale) }
    scope :for_default_locale, -> { for_locale(I18n.default_locale) }

    has_one :lock, as: :on, dependent: :destroy
    sir_trevor_content :content
    has_paper_trail

    accepts_nested_attributes_for :thumbnail, update_only: true, reject_if: proc { |attr| attr['iiif_tilesource'].blank? }

    # display_sidebar should be set to true by default
    before_create do
      self.content ||= [].to_json
      self.display_sidebar = true
    end

    after_update :update_translated_pages_weights_and_parent_page

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
    alias has_content? content?

    def display_sidebar?
      true
    end

    def featured_image
      nil
    end

    def thumbnail_image_url
      return unless thumbnail && thumbnail.iiif_url
      thumbnail.iiif_url
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

    def home_page?
      is_a? HomePage
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

    def updated_after?(other_page)
      return false unless other_page
      updated_at > other_page.updated_at
    end

    def translated_page_for(locale)
      translated_pages.for_locale(locale).first
    end

    def clone_for_locale(locale)
      dup.tap do |np|
        np.locale = locale
        np.default_locale_page = self
        np.published = false

        if !top_level_page? && (parent_translation = parent_page.translated_page_for(locale)).present?
          np.parent_page = parent_translation
        end

        child_pages.for_locale(locale).update(parent_page: np) if top_level_page? && respond_to?(:child_pages)
      end
    end

    private

    def update_translated_pages_weights_and_parent_page
      return unless locale.to_sym == I18n.default_locale
      return unless saved_change_to_weight? || saved_change_to_parent_page_id?
      update_params = {}
      update_params[:weight] = weight if saved_change_to_weight?
      update_params[:parent_page_id] = parent_page_id if saved_change_to_parent_page_id?
      translated_pages.update(update_params)
    end
  end
  # rubocop:enable Metrics/ClassLength
end
