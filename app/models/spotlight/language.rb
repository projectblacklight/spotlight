module Spotlight
  # A language for an exhibit
  class Language < ActiveRecord::Base
    belongs_to :exhibit
    validates :locale, presence: true

    def to_native
      Spotlight::Engine.config.i18n_locales[locale.downcase.to_sym] || ''
    end

    def self.default_instance
      new(locale: I18n.default_locale)
    end
  end
end
