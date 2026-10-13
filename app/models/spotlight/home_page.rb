# frozen_string_literal: true

module Spotlight
  ##
  # Exhibit home page
  class HomePage < Spotlight::Page
    extend FriendlyId

    friendly_id :title, use: %i[slugged scoped finders history], scope: %i[exhibit locale] do |config|
      config.reserved_words&.concat(%w[update_all])
    end

    before_save :publish
    before_create :default_content

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
      self[:content_type] ||= default_content_type
    end

    # Home pages are created with the exhibit, so curators don't get to pick an editor.
    # When there is a choice of editors, use the first (preselected) one, like the "Add new page" form.
    def default_content_type
      content_types = Spotlight::Engine.config.page_content_types
      content_types.first if content_types.many?
    end
  end
end
