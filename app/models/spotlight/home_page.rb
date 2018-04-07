module Spotlight
  ##
  # Exhibit home page
  class HomePage < Spotlight::Page
    extend FriendlyId
    friendly_id :title, use: [:slugged, :scoped, :finders], scope: [:exhibit, :locale]

    before_save :publish
    before_create :default_content

    accepts_nested_attributes_for :thumbnail, update_only: true, reject_if: proc { |attr| attr['iiif_tilesource'].blank? }

    class << self
      def default_title_text
        I18n.t('spotlight.pages.index.home_pages.title')
      end
    end

    def should_display_title?
      display_title?
    end

    def display_sidebar?
      display_sidebar
    end

    private

    def publish
      self.published = true
    end

    def default_content
      self.title ||= Spotlight::HomePage.default_title_text
    end
  end
end
