require 'i18n/backend/active_record'
require 'i18n/backend/fallbacks'

Translation = I18n::Backend::ActiveRecord::Translation

if Translation.table_exists?
  ##
  # Sets up the new Spotlight Translation backend, backed by ActiveRecord. To
  # turn on the ActiveRecord backend, uncomment the following lines.

  I18n.backend = I18n::Backend::ActiveRecord.new
  I18n::Backend::ActiveRecord.send(:include, I18n::Backend::Memoize)
  Translation.send(:include, Spotlight::CustomTranslationExtension)
  I18n::Backend::Simple.send(:include, I18n::Backend::Memoize)
  I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)

  I18n.backend = I18n::Backend::Chain.new(I18n.backend, I18n::Backend::Simple.new)
end
