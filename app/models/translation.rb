# frozen_string_literal: true

require 'i18n/backend/active_record'

unless defined?(Translation)
  Translation = I18n::Backend::ActiveRecord::Translation
  Translation.include Spotlight::CustomTranslationExtension

  # Work-around for https://github.com/svenfuchs/i18n-active_record/pull/133
  if Translation.respond_to?(:to_hash)
    class << Translation
      alias to_h to_hash
      remove_method :to_hash
    end

    I18n::Backend::ActiveRecord.define_method(:init_translations) do
      @translations = Translation.to_h
    end
  end
end
