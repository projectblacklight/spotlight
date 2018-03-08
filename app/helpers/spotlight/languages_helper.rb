module Spotlight
  ##
  # Helpers for the Language form and UI elements
  module LanguagesHelper
    def add_exhibit_language_dropdown_options
      non_default_or_current_exhibit_languages = I18n.available_locales.reject do |locale|
        locale == I18n.default_locale || current_exhibit.available_locales.include?(locale.to_s)
      end

      non_default_or_current_exhibit_languages_with_labels = non_default_or_current_exhibit_languages.map do |locale|
        [t("locales.#{locale.downcase}"), locale]
      end

      non_default_or_current_exhibit_languages_with_labels.sort_by { |label, _locale| label }
    end
  end
end
