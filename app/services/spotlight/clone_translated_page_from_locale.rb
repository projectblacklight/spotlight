# frozen_string_literal: true

module Spotlight
  ##
  # A service class to encapsulate business logic
  # around cloning and destroying translated pages
  class CloneTranslatedPageFromLocale
    attr_reader :locale, :page

    def initialize(locale:, page:)
      @locale = locale
      @page = page
    end

    def self.call(locale:, page:)
      new(locale:, page:).clone
    end

    def clone
      destroy
      page.clone_for_locale(locale)
    end

    private

    def destroy
      page.translated_page_for(locale).destroy if page.translated_page_for(locale).present?
    end
  end
end
