# frozen_string_literal: true

module Spotlight
  # Displays a message that this exhibit information cannot be edited in the
  # currently selected language and provides other options.
  class UneditableNonDefaultLanguageComponent < ViewComponent::Base
    def initialize(current_exhibit:, current_language:)
      @current_exhibit = current_exhibit
      @current_language = current_language
      super()
    end

    def edit_translations_button
      link_to I18n.t('spotlight.exhibits.form.uneditable_non_default_language_form.translations'),
              helpers.spotlight.edit_exhibit_translations_path(@current_exhibit, locale: @current_language),
              class: 'btn btn-primary'
    end

    def switch_to_default_language_button
      link_to I18n.t('spotlight.exhibits.form.uneditable_non_default_language_form.default_language'),
              helpers.spotlight.edit_exhibit_path(@current_exhibit, locale: I18n.default_locale),
              class: 'btn btn-primary'
    end
  end
end
