module Spotlight
  ##
  # Module that extends I18n::Backend::ActiveRecord::Translation to provide
  # additional Spotlight behavior, such as exhibit specific Translations
  module CustomTranslationExtension
    extend ActiveSupport::Concern

    included do
      belongs_to :exhibit, class_name: 'Spotlight::Exhibit', inverse_of: :translations
    end

    class_methods do
      def exhibit_default_scope(exhibit)
        default_scope { where(exhibit: exhibit) }
      end
    end
  end
end
