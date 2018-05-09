module Spotlight
  # A language for an exhibit
  class Language < ActiveRecord::Base
    belongs_to :exhibit
    has_many :pages, ->(page) { where(locale: page.locale) }, through: :exhibit
    has_many :translations, ->(translation) { where(locale: translation.locale) }, through: :exhibit
    validates :locale, presence: true

    # Doing this instead of dependent: :destroy because
    # has_many :through can't associate a has_many reflection
    after_destroy do
      pages.map(&:destroy)
      translations.map(&:destroy)
    end

    def to_native
      Spotlight::Engine.config.i18n_locales[locale.to_sym] || ''
    end

    def self.default_instance
      new(locale: I18n.default_locale)
    end
  end
end
